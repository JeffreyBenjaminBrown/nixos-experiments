#!/usr/bin/env bash
# Step 4: copy the updated config into /etc/nixos/ and do a DRY BUILD
# (no activation / switch) to verify everything evaluates and builds.
#
# - Runs bash/copy.sh to stage the new config (incl. monome.nix and
#   custom-packages/) into /etc/nixos/.
# - Runs `sudo nixos-rebuild build` which builds the system derivation
#   but does NOT activate it. No reboot needed, no services touched.
# - Dumps full output to 04-rebuild-dry.out.
#
# If this succeeds, step 5 will be a real `switch`. If it fails, read
# the output file and tell Claude.
#
# Output: ./04-rebuild-dry.out

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/04-rebuild-dry.out"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

{
  echo "================================================================"
  echo "=== REBUILD DRY    $(date -Iseconds)"
  echo "================================================================"
  echo "Repo root: $REPO_ROOT"

  echo
  echo "--- config/monome.nix ---"
  cat "$REPO_ROOT/config/monome.nix"

  echo
  echo "--- Staging into /etc/nixos/ via bash/copy.sh ---"
  cd "$REPO_ROOT"
  sudo bash ./bash/copy.sh 2>&1 || { echo "copy.sh failed"; exit 1; }

  echo
  echo "--- /etc/nixos after copy ---"
  ls -la /etc/nixos/ 2>&1
  echo
  echo "--- /etc/nixos/custom-packages/ ---"
  ls /etc/nixos/custom-packages/ 2>&1 || true

  echo
  echo "--- sudo nixos-rebuild build ---"
  sudo nixos-rebuild build 2>&1

  echo
  echo "--- Did it produce a ./result symlink? ---"
  cd "$REPO_ROOT"
  ls -la result 2>&1 || echo "(no result symlink in repo root)"

  echo "=== END REBUILD DRY ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
