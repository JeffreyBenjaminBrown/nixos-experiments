#!/usr/bin/env bash
# Standalone build of the new libmonome derivation.
#
# Expected first-run behavior: nix will fail with a "hash mismatch"
# message because the derivation uses lib.fakeHash. Copy the "got:"
# value from the error output into the hash field of default.nix, then
# re-run this script. (Claude will do the paste if you drop the
# output file in front of him.)
#
# Output: ./02-build-libmonome.out (plus a ./result symlink on success)

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/02-build-libmonome.out"
LIBMONOME_DIR="$HERE/../libmonome"

{
  echo "================================================================"
  echo "=== BUILD libmonome    $(date -Iseconds)"
  echo "================================================================"

  echo "--- derivation being built ---"
  cat "$LIBMONOME_DIR/default.nix"

  echo
  echo "--- nix --version ---"
  nix --version 2>&1 || true

  echo
  echo "--- nix-build (stderr merged) ---"
  # Use nix-build against a tiny wrapper so we can callPackage with stdenv from <nixpkgs>.
  # Keep the result symlink in this script's directory.
  cd "$HERE"
  rm -f result
  nix-build -E '
    let pkgs = import <nixpkgs> {}; in
    pkgs.callPackage '"$LIBMONOME_DIR"'/default.nix {}
  ' 2>&1

  echo
  echo "--- if build succeeded, show the result tree ---"
  if [ -e result ]; then
    echo "result -> $(readlink result)"
    echo
    echo "  bin/:"
    ls -la result/bin/ 2>&1 || echo "  (no bin/)"
    echo
    echo "  lib/:"
    ls -la result/lib/ 2>&1 || echo "  (no lib/)"
    echo
    echo "  include/:"
    ls -la result/include/ 2>&1 || echo "  (no include/)"
    echo
    echo "  pkgconfig:"
    find result -name '*.pc' -exec cat {} \; 2>&1 || true
  else
    echo "(no result symlink — build did not succeed)"
  fi

  echo "=== END BUILD libmonome ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
