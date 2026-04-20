#!/usr/bin/env bash
# Step 5: real `nixos-rebuild switch` + verify serialoscd runs.
#
# Pre: step 4 (dry build) succeeded.
#
# What this does:
# 1. Stages /etc/nixos/ via bash/copy.sh (idempotent; same as step 4).
# 2. Runs `sudo nixos-rebuild switch` — this activates the new
#    configuration (links /run/current-system, reloads systemd, etc.).
# 3. Tells the current user's systemd to reload unit files and start
#    the new serialoscd.service, so we don't have to log out/in.
# 4. Shows service status and recent logs.
# 5. If a monome is plugged in, tries to list it via netcat/UDP on
#    the OSC port serialosc registers (12002 on the discovery side).
#
# Output: ./05-switch-and-verify.out

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/05-switch-and-verify.out"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

{
  echo "================================================================"
  echo "=== SWITCH + VERIFY    $(date -Iseconds)"
  echo "================================================================"

  echo "--- Staging via bash/copy.sh ---"
  cd "$REPO_ROOT"
  sudo bash ./bash/copy.sh 2>&1 || { echo "copy.sh failed"; exit 1; }

  echo
  echo "--- sudo nixos-rebuild switch --keep-failed ---"
  sudo nixos-rebuild switch --keep-failed 2>&1

  echo
  echo "--- systemctl --user daemon-reload + start serialoscd ---"
  systemctl --user daemon-reload 2>&1 || true
  systemctl --user start serialoscd.service 2>&1 || true
  # Don't `enable` — NixOS's wantedBy already creates the symlink.

  echo
  echo "--- systemctl --user status serialoscd (no-pager) ---"
  systemctl --user status serialoscd.service --no-pager 2>&1 || true

  echo
  echo "--- recent serialoscd logs (journalctl --user -u serialoscd -n 50) ---"
  journalctl --user -u serialoscd.service -n 50 --no-pager 2>&1 || true

  echo
  echo "--- /dev/ttyUSB* (is the monome present?) ---"
  ls -l /dev/ttyUSB* /dev/ttyACM* 2>&1 || true

  echo
  echo "--- binaries on PATH ---"
  command -v serialoscd && serialoscd --help 2>&1 | head -5 || true
  command -v serialosc-detector || true
  command -v serialosc-device || true

  echo
  echo "--- if monome plugged in: probe discovery port 12002 ---"
  # serialosc advertises devices on UDP/12002 via OSC. Send a /serialosc/list
  # OSC message; any connected grid should respond.
  # This is a best-effort probe — requires oscsend (liblo-utils) or we skip.
  if command -v oscsend >/dev/null 2>&1; then
    echo "(oscsend available — sending /serialosc/list to localhost:12002)"
    oscsend localhost 12002 /serialosc/list si "localhost" 9999 2>&1 || true
    # Set up a brief listener on 9999 to catch the reply
    if command -v oscdump >/dev/null 2>&1; then
      timeout 2 oscdump 9999 2>&1 || true
    fi
  else
    echo "(oscsend/oscdump not installed — skipping OSC probe; use monome software to test)"
  fi

  echo "=== END SWITCH + VERIFY ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
