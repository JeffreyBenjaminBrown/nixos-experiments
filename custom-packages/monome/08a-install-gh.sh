#!/usr/bin/env bash
# Step 8a: rebuild with `gh` added to packages.nix, then run `gh auth login`.
#
# gh (the GitHub CLI) is needed by step 8 for `gh repo sync` and the
# eventual `gh pr create`. It's now listed in config/packages.nix;
# this script stages and switches so the binary lands on PATH.
#
# After the switch succeeds, the script drops you into `gh auth login`
# (interactive). Follow its prompts: choose GitHub.com, then "HTTPS",
# then paste the one-time code it shows you into the browser window
# it opens.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/08a-install-gh.out"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

exec 3>&1
progress() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&3; }

progress "starting; full log -> $OUT"

{
  echo "================================================================"
  echo "=== INSTALL GH    $(date -Iseconds)"
  echo "================================================================"

  progress "sudo bash ./bash/copy.sh"
  cd "$REPO_ROOT"
  sudo bash ./bash/copy.sh 2>&1

  progress "sudo nixos-rebuild switch (small delta; should be quick)"
  sudo nixos-rebuild switch 2>&1

  progress "verifying gh on PATH"
  command -v gh 2>&1 || { progress "gh still not found; something went wrong"; exit 1; }
  gh --version 2>&1 | head -3

  echo "=== END INSTALL GH ==="
} >"$OUT" 2>&1

progress "rebuild done; now run: gh auth login"
echo
echo "Next step (interactive — NOT captured to the log file):"
echo
echo "  gh auth login"
echo
echo "Then re-run step 8:"
echo
echo "  bash $HERE/08-prep-nixpkgs-fork.sh"
