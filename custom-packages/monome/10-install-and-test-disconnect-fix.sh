#!/usr/bin/env bash
# Build, install, and live-test the targeted serialosc disconnect fix.
# Run on the NixOS host from any directory. The script beeps when it is time
# to unplug the monome and records its findings beside this file.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"
BUILD_OUT="$HERE/03-build-serialosc.out"
OUT="$HERE/10-install-and-test-disconnect-fix.out"

exec > >(tee "$OUT") 2>&1

echo "serialosc targeted-fix install/test: $(date -Iseconds)"
echo "repository: $REPO_ROOT"

echo
echo "[1/4] Building the patched packages"
"$HERE/03-build-serialosc.sh"
if [ ! -x "$HERE/result/bin/serialosc-device" ]; then
  echo "ERROR: patched serialosc did not build; see $BUILD_OUT"
  exit 1
fi
if ! grep -q 'Checking for working poll().*: yes' "$BUILD_OUT"; then
  echo "ERROR: build succeeded but did not select the poll event loop."
  grep 'Checking for working poll()' "$BUILD_OUT" || true
  exit 1
fi
grep 'Checking for working poll()' "$BUILD_OUT"
echo "built result: $(readlink -f "$HERE/result")"

echo
echo "[2/4] Staging the Nix configuration and switching the host"
cd "$REPO_ROOT"
sudo ./bash/copy.sh
if ! sudo nixos-rebuild switch --keep-failed --cores 2 --max-jobs 1; then
  echo "ERROR: nixos-rebuild failed; the live system was not switched."
  exit 1
fi

echo
echo "[3/4] Restarting serialosc and locating its device process"
systemctl --user daemon-reload
systemctl --user restart serialoscd.service

supervisor_pid="$(systemctl --user show serialoscd.service --property MainPID --value)"
if [ -z "$supervisor_pid" ] || [ "$supervisor_pid" = 0 ]; then
  echo "ERROR: serialoscd.service has no running supervisor process."
  systemctl --user status serialoscd.service --no-pager || true
  exit 1
fi
echo "supervisor process: $supervisor_pid"

echo
echo "PLUG THE MONOME IN NOW. The script will wait for it."
if [ -x "$REPO_ROOT/../my-dot-claude/hooks/beep-if-main-agent.sh" ]; then
  printf '{}' | "$REPO_ROOT/../my-dot-claude/hooks/beep-if-main-agent.sh" beep-glorious || true
fi

device_path=""
for _ in $(seq 1 20); do
  for candidate in /dev/serial/by-id/* /dev/ttyACM* /dev/ttyUSB*; do
    if [ -e "$candidate" ]; then
      device_path="$(readlink -f "$candidate")"
      break 2
    fi
  done
  sleep 0.5
done
if [ -z "$device_path" ]; then
  echo "ERROR: no monome serial device appeared after 10 seconds."
  exit 1
fi
echo "device node appeared: $device_path"

# Only accept a real serialosc-device executable launched directly by the
# current systemd-managed serialoscd. A command-line grep can accidentally
# select strace itself because its arguments mention serialosc-device.
find_device_pid() {
  local pid exe parent cmdline
  for pid in $(pgrep -P "$supervisor_pid" 2>/dev/null || true); do
    exe="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
    [ "$(basename "$exe")" = serialosc-device ] || continue
    parent="$(awk '/^PPid:/ { print $2 }' "/proc/$pid/status" 2>/dev/null || true)"
    [ "$parent" = "$supervisor_pid" ] || continue
    cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
    case "$cmdline" in
      *"$device_path"*) echo "$pid"; return 0 ;;
    esac
  done
  return 1
}

device_pid=""
for _ in $(seq 1 30); do
  device_pid="$(find_device_pid || true)"
  [ -n "$device_pid" ] && break
  sleep 1
done

if [ -z "$device_pid" ]; then
  echo "ERROR: no serialosc-device process appeared after 30 seconds."
  systemctl --user status serialoscd.service --no-pager || true
  exit 1
fi

echo "device process before unplug:"
ps -o pid,ppid,stat,pcpu,etime,cmd -p "$device_pid"

echo
echo "[4/4] UNPLUG THE MONOME WHEN THE BEEP SOUNDS"
echo "The script will wait up to 20 seconds."
if [ -x "$REPO_ROOT/../my-dot-claude/hooks/beep-if-main-agent.sh" ]; then
  printf '{}' | "$REPO_ROOT/../my-dot-claude/hooks/beep-if-main-agent.sh" beep-harsh || true
elif command -v pw-play >/dev/null 2>&1 && [ -e /home/sound/beep-harsh.wav ]; then
  pw-play /home/sound/beep-harsh.wav >/dev/null 2>&1 &
fi

unplugged=0
for _ in $(seq 1 40); do
  if [ ! -e "$device_path" ]; then
    unplugged=1
    break
  fi
  sleep 0.5
done
if [ "$unplugged" -ne 1 ]; then
  echo "ERROR: $device_path still exists; no unplug was observed after 20 seconds."
  exit 1
fi
echo "device node disappeared; checking whether serialosc-device exits"

exited=0
for _ in $(seq 1 20); do
  if ! kill -0 "$device_pid" 2>/dev/null; then
    exited=1
    break
  fi
  sleep 0.5
done

echo
if [ "$exited" -eq 1 ]; then
  echo "PASS: serialosc-device $device_pid exited promptly after unplug."
else
  echo "FAIL: serialosc-device $device_pid is still alive 10 seconds after unplug."
  ps -o pid,ppid,stat,pcpu,etime,wchan:24,cmd -p "$device_pid" || true
fi

echo
echo "recent service log:"
journalctl --user -u serialoscd.service -n 40 --no-pager || true
echo
echo "full output: $OUT"

if [ "$exited" -ne 1 ]; then
  exit 1
fi
