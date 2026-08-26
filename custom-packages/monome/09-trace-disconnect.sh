#!/usr/bin/env bash
# Capture the kernel-visible serialosc-device behavior during USB unplug.
# Run this on the NixOS host, not inside the development container.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/09-trace-disconnect.out"
TRACE="$HERE/09-trace-disconnect.strace"

restart_service() {
  systemctl --user start serialoscd.service >/dev/null 2>&1 || true
}
trap restart_service EXIT INT TERM

exec > >(tee "$OUT") 2>&1

echo "serialosc disconnect trace: $(date -Iseconds)"
echo "host: ${HOSTNAME:-unknown}"

if ! command -v strace >/dev/null 2>&1; then
  echo "ERROR: strace is not on PATH. Run: nix-shell -p strace"
  echo "Then run this script again from that shell."
  exit 1
fi

device=""
for candidate in /dev/serial/by-id/* /dev/ttyACM* /dev/ttyUSB*; do
  if [ -e "$candidate" ]; then
    device="$(readlink -f "$candidate")"
    break
  fi
done
if [ -z "$device" ]; then
  echo "ERROR: no /dev/serial/by-id, /dev/ttyACM, or /dev/ttyUSB device found."
  exit 1
fi

device_program="$(command -v serialosc-device 2>/dev/null || true)"
if [ -z "$device_program" ]; then
  daemon_program="$(command -v serialoscd 2>/dev/null || true)"
  if [ -n "$daemon_program" ]; then
    candidate="$(dirname "$(readlink -f "$daemon_program")")/serialosc-device"
    [ -x "$candidate" ] && device_program="$candidate"
  fi
fi
if [ -z "$device_program" ]; then
  echo "ERROR: serialosc-device is not on PATH or beside serialoscd."
  exit 1
fi

echo "device: $device"
echo "program: $device_program"
echo "stopping serialoscd.service so the traced process has exclusive access"
systemctl --user stop serialoscd.service || exit 1

: > "$TRACE"
echo
echo "UNPLUG THE MONOME WHEN THE BEEP SOUNDS."
echo "The trace has a hard 15-second limit."
if [ -x "$HERE/../../../my-dot-claude/hooks/beep-if-main-agent.sh" ]; then
  printf '{}' | "$HERE/../../../my-dot-claude/hooks/beep-if-main-agent.sh" beep-harsh || true
elif command -v pw-play >/dev/null 2>&1 && [ -e /home/sound/beep-harsh.wav ]; then
  pw-play /home/sound/beep-harsh.wav >/dev/null 2>&1 &
fi

# Keep strace in the foreground so serialosc-device inherits the terminal as
# stdin.  A background job in a non-interactive shell gets /dev/null instead;
# serialosc mistakes that for a supervisor IPC pipe and spins on EOF.  timeout
# owns the whole foreground process group and SIGKILLs it if TERM is ignored.
timeout --kill-after=2s 15s \
  strace -f -tt -T -yy -s 128 \
    -e trace=poll,ppoll,select,pselect6,read,close \
    -o "$TRACE" \
    "$device_program" "$device" || true

echo
echo "last 80 traced syscalls:"
tail -n 80 "$TRACE"
echo
echo "full outputs:"
echo "  $OUT"
echo "  $TRACE"
echo "serialoscd.service will now be restarted"
