#!/usr/bin/env bash
# Step 7: rebuild serialosc with the zeroconf dlopen fix, switch, and
# verify the "couldn't load libdns_sd.so" message no longer appears.
#
# Changes already made in custom-packages/serialosc/default.nix:
# - Added `makeWrapper` to nativeBuildInputs.
# - Added postInstall that wraps $out/bin/serialoscd with
#   LD_LIBRARY_PATH=<avahi-compat>/lib so the runtime dlopen finds
#   libdns_sd.so.
#
# This script:
# 1. Copies new config into /etc/nixos (so the derivation change lands).
# 2. nixos-rebuild switch.
# 3. systemctl --user restart serialoscd.
# 4. Checks the journal for the zeroconf error message post-restart.
#
# Output: ./07-fix-zeroconf.out

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/07-fix-zeroconf.out"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

{
  echo "================================================================"
  echo "=== FIX ZEROCONF    $(date -Iseconds)"
  echo "================================================================"

  echo "--- serialosc derivation (for sanity) ---"
  cat "$REPO_ROOT/custom-packages/serialosc/default.nix"

  echo
  echo "--- sudo bash ./bash/copy.sh ---"
  cd "$REPO_ROOT"
  sudo bash ./bash/copy.sh 2>&1

  echo
  echo "--- sudo nixos-rebuild switch ---"
  sudo nixos-rebuild switch 2>&1

  echo
  echo "--- systemctl --user daemon-reload + restart serialoscd ---"
  systemctl --user daemon-reload 2>&1 || true
  systemctl --user restart serialoscd.service 2>&1 || true
  sleep 0.5

  echo
  echo "--- serialoscd status ---"
  systemctl --user status serialoscd.service --no-pager 2>&1 || true

  echo
  echo "--- recent journal (last 30) ---"
  journalctl --user -u serialoscd.service -n 30 --no-pager 2>&1 || true

  echo
  echo "--- grep for the zeroconf error post-restart ---"
  # Restrict to SINCE we restarted. Use a cursor: look for "Started" line
  # from this boot's latest unit start.
  RESTARTED_SINCE="$(journalctl --user -u serialoscd.service --no-pager 2>&1 | grep -E 'Started serialosc' | tail -n 1 | awk '{print $1, $2, $3}')"
  echo "latest start: $RESTARTED_SINCE"
  if journalctl --user -u serialoscd.service --no-pager --since "$RESTARTED_SINCE" 2>&1 | grep -q "couldn't load libdns_sd"; then
    echo "STILL FAILING: zeroconf error present after restart"
  else
    echo "FIXED: no zeroconf error since last restart"
  fi

  echo "=== END FIX ZEROCONF ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
