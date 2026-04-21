#!/usr/bin/env bash
# Standalone build of the new serialosc derivation.
#
# Depends on ../libmonome/default.nix building successfully first
# (step 2). This script callPackages libmonome into a set and then
# callPackages serialosc with that libmonome injected, so both
# derivations are exercised together.
#
# Expected first-run behavior: hash mismatch, same as step 2.
# After the hash is patched, a second run should complete the build.
#
# Output: ./03-build-serialosc.out (plus a ./result symlink on success)

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/03-build-serialosc.out"
LIBMONOME_DIR="$HERE/../libmonome"
SERIALOSC_DIR="$HERE/../serialosc"

{
  echo "================================================================"
  echo "=== BUILD serialosc    $(date -Iseconds)"
  echo "================================================================"

  echo "--- serialosc derivation ---"
  cat "$SERIALOSC_DIR/default.nix"

  echo
  echo "--- nix-build (stderr merged) ---"
  cd "$HERE"
  rm -f result
  nix-build -E '
    let
      pkgs = import <nixpkgs> {};
      libmonome = pkgs.callPackage '"$LIBMONOME_DIR"'/default.nix {};
    in
      pkgs.callPackage '"$SERIALOSC_DIR"'/default.nix { inherit libmonome; }
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
    echo "  share/ (recursive):"
    find result/share -maxdepth 4 2>&1 || echo "  (no share/)"
    echo
    echo "  serialoscd --help (first 20 lines):"
    result/bin/serialoscd --help 2>&1 | head -n 20 || true
  else
    echo "(no result symlink — build did not succeed)"
  fi

  echo "=== END BUILD serialosc ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
