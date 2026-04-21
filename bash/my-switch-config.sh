#!/usr/bin/env bash
# Activate the latest build of a named system profile.
# Usage: my-switch-config.sh <profile-name>
#
# Profile names must match those passed to
# `nixos-rebuild switch --profile-name ...` (see bash/rebuild-branches.sh).
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $(basename "$0") <profile-name>" >&2
    echo "available profiles:" >&2
    ls /nix/var/nix/profiles/system-profiles/ 2>/dev/null >&2 || true
    exit 2
fi

profile="/nix/var/nix/profiles/system-profiles/$1"
if [[ ! -e "$profile" ]]; then
    echo "no such profile: $profile" >&2
    exit 1
fi

sudo "$profile"/bin/switch-to-configuration switch
