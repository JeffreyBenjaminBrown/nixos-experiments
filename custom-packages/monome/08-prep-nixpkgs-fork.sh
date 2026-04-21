#!/usr/bin/env bash
# Step 8: stage a nixpkgs PR for libmonome + serialosc.
#
# Jeff already has https://github.com/JeffreyBenjaminBrown/nixpkgs as
# a fork, but it's years out of date. We work around that by:
#   - Cloning blobless (--filter=blob:none --single-branch) from
#     NixOS/nixpkgs. Full commit history, file contents on demand.
#     ~300-500 MB instead of 4.7 GB full / instead of shallow's
#     push-time boundary risks.
#   - Leaving the fork's GitHub-side master to be sync'd via
#     `gh repo sync` when we're ready to push (server-side, no bytes
#     transferred from this machine).
#
# What this script does:
# 1. Shallow-clones NixOS/nixpkgs to ~/code/nix/nixpkgs.
# 2. Renames remotes so upstream=NixOS, origin=the fork.
# 3. Creates branch jbb/libmonome-serialosc off upstream/master.
# 4. Drops package.nix files into pkgs/by-name/{li/libmonome,se/serialosc}/
# 5. Two commits, one per package.
# 6. Runs nix-build -A on each to verify.
# 7. `gh repo sync` to bring the fork's master up to date (server-side).
# 8. `git push -u origin $BRANCH` to push the branch to the fork.
# 9. Prints ONLY the `gh pr create` command for you to run manually
#    — that's the step that's visible to nixpkgs maintainers.
#
# Output: ./08-prep-nixpkgs-fork.out

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/08-prep-nixpkgs-fork.out"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"
FORK_DIR="$HOME/code/nix/nixpkgs"
UPSTREAM_URL="https://github.com/NixOS/nixpkgs.git"
# HTTPS URL for the fork. We tried SSH first but your ssh-agent state
# made pushes fail with GitHub "Bye Bye" disconnects. HTTPS+gh works
# everywhere: `gh auth setup-git` (run below) makes git call gh to
# provide a token for https:// remotes.
FORK_URL="https://github.com/JeffreyBenjaminBrown/nixpkgs.git"
BRANCH="jbb/libmonome-serialosc"
SRC_LIBMONOME="$REPO_ROOT/custom-packages/for-nixpkgs/libmonome/package.nix"
SRC_SERIALOSC="$REPO_ROOT/custom-packages/for-nixpkgs/serialosc/package.nix"

# fd 3 = the real terminal, so progress lines can print live while the
# verbose output of each command still goes to $OUT via the block redirect.
exec 3>&1
progress() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&3; }

progress "starting; full log -> $OUT"

{
  echo "================================================================"
  echo "=== PREP NIXPKGS FORK    $(date -Iseconds)"
  echo "================================================================"

  echo "--- partial clone nixpkgs (blobless) ---"
  if [ -d "$FORK_DIR/.git" ]; then
    progress "reusing existing clone at $FORK_DIR; fetching latest"
    echo "reusing existing clone at $FORK_DIR"
    cd "$FORK_DIR"
    git fetch upstream master 2>&1 || git fetch origin master 2>&1
  else
    progress "cloning nixpkgs blobless+single-branch (~300-500 MB; 1-3 min)"
    mkdir -p "$(dirname "$FORK_DIR")"
    # --filter=blob:none: partial clone. Pulls full commit history and
    # trees but fetches file contents only on demand. Avoids the 4.7 GB
    # full-clone cost AND avoids the fragility of shallow clones when
    # pushing (shallow boundaries can confuse push-pack negotiation).
    # --single-branch: skip the hundreds of release/staging branches.
    git clone --filter=blob:none --single-branch --branch master \
      "$UPSTREAM_URL" "$FORK_DIR" 2>&1
    cd "$FORK_DIR"
  fi
  progress "clone/fetch done"

  echo
  echo "--- set remotes: upstream=NixOS, origin=fork ---"
  # Normalize regardless of clone state.
  if git remote | grep -qx origin; then
    git remote set-url origin "$FORK_URL"
  else
    git remote add origin "$FORK_URL"
  fi
  if git remote | grep -qx upstream; then
    git remote set-url upstream "$UPSTREAM_URL"
  else
    git remote add upstream "$UPSTREAM_URL"
  fi
  git remote -v 2>&1

  echo
  echo "--- (re)create branch $BRANCH off upstream/master ---"
  progress "creating branch $BRANCH off upstream/master"
  git fetch upstream master 2>&1
  git checkout -B master upstream/master 2>&1
  git branch -D "$BRANCH" 2>/dev/null || true
  git checkout -b "$BRANCH" 2>&1

  echo
  echo "--- commit libmonome ---"
  progress "committing libmonome"
  mkdir -p pkgs/by-name/li/libmonome
  cp "$SRC_LIBMONOME" pkgs/by-name/li/libmonome/package.nix
  git add pkgs/by-name/li/libmonome/package.nix
  git commit -m "libmonome: init at 1.4.9

C library for interacting with monome devices (grids, arcs).

https://monome.org
https://github.com/monome/libmonome

ISC licensed. Upstream uses CMake and only requires libudev at
build/runtime on Linux." 2>&1

  echo
  echo "--- commit serialosc ---"
  progress "committing serialosc"
  mkdir -p pkgs/by-name/se/serialosc
  cp "$SRC_SERIALOSC" pkgs/by-name/se/serialosc/package.nix
  git add pkgs/by-name/se/serialosc/package.nix
  git commit -m "serialosc: init at 1.4.7

Multi-device, Bonjour-capable OSC server for monome devices.

https://monome.org
https://github.com/monome/serialosc

ISC licensed. Depends on libmonome (added in the previous commit),
liblo, libuv, and avahi-compat. The daemon dlopens libdns_sd.so at
runtime for zeroconf, so the installed binary is wrapped to put
avahi-compat on LD_LIBRARY_PATH." 2>&1

  echo
  echo "--- branch log ---"
  git log upstream/master..$BRANCH --oneline 2>&1

  echo
  echo "--- nix-build -A libmonome ---"
  progress "nix-build -A libmonome (mostly cached already; seconds)"
  nix-build -A libmonome --no-out-link 2>&1 | tail -n 15

  echo
  echo "--- nix-build -A serialosc ---"
  progress "nix-build -A serialosc (mostly cached already; seconds)"
  nix-build -A serialosc --no-out-link 2>&1 | tail -n 15

  echo
  echo "--- sanity: gh CLI authenticated? ---"
  progress "checking gh auth"
  if ! gh auth status 2>&1; then
    progress "gh not authenticated — aborting; run: gh auth login"
    echo "gh CLI is not authenticated; cannot sync fork or push via gh."
    echo "Run 'gh auth login' and then re-run this script."
    exit 1
  fi

  echo
  echo "--- gh auth setup-git (configure git to use gh as credential helper) ---"
  progress "gh auth setup-git (one-time; idempotent)"
  gh auth setup-git 2>&1

  echo
  echo "--- gh repo sync JeffreyBenjaminBrown/nixpkgs ---"
  progress "gh repo sync (server-side; should take ~1-2 s)"
  # If upstream has workflow-file changes, gh needs the `workflow`
  # scope on its OAuth token. If missing, add it with:
  #   gh auth refresh -s workflow
  gh repo sync JeffreyBenjaminBrown/nixpkgs 2>&1 || {
    progress "gh repo sync failed (often: need workflow scope)"
    echo "If the error mentions 'workflow' scope, run manually:"
    echo "  gh auth refresh -s workflow"
    echo "and then re-run this script."
    exit 1
  }

  echo
  echo "--- git push -u origin $BRANCH ---"
  progress "pushing branch $BRANCH to origin (your fork)"
  git push -u origin "$BRANCH" 2>&1
  progress "push done"

  echo
  echo "--- manual follow-up: open the PR ---"
  cat <<EOF
  Review the diff above, then open the PR yourself:

    gh pr create --repo NixOS/nixpkgs \\
      --base master \\
      --head JeffreyBenjaminBrown:$BRANCH \\
      --title "libmonome, serialosc: init" \\
      --body "Adds libmonome 1.4.9 and serialosc 1.4.7 as two by-name packages.
Tested end-to-end on NixOS 26.05 (unstable) with a monome 256 grid.
Replaces the closed prior attempt #78659."

  (This is left manual because it pings nixpkgs maintainers.)
EOF

  echo "=== END PREP NIXPKGS FORK ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
echo "Checkout at: $FORK_DIR on branch $BRANCH"
