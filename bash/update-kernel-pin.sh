#!/usr/bin/env bash
# Update the system channel, then pin the RT kernel to that exact channel
# snapshot.  This intentionally makes the next NixOS rebuild compile the new
# RT kernel.
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
config_file="$repo_root/config/audio-configuration.nix"

if [[ ! -f "$config_file" ]]; then
    echo "cannot find $config_file" >&2
    exit 1
fi

# Refuse to update the channel if the file no longer has the pin this script
# owns, rather than silently editing an unrelated configuration shape.
if ! perl -0ne 'exit 1 unless /kernelNixpkgsVersion = "[^"]+";\n  kernelNixpkgsSha256 = "[^"]+";/' "$config_file"; then
    echo "could not find the RT kernel pin in $config_file" >&2
    exit 1
fi

sudo nix-channel --update nixos

channel_url="$(sudo nix-channel --list | awk '
    $1 == "nixos" { url = $2 }
    END {
        if (url == "") exit 1
        print url
    }
')"
if [[ -z "$channel_url" ]]; then
    echo "the root nixos channel has no URL" >&2
    exit 1
fi

case "$channel_url" in
    */nixexprs.tar.xz) tarball_url="$channel_url" ;;
    *)                 tarball_url="${channel_url%/}/nixexprs.tar.xz" ;;
esac

# Channels redirect to immutable releases.nixos.org snapshots.  Save that
# target, not the moving channel URL, so the pin cannot drift later.
resolved_url="$(curl --fail --silent --show-error --location --output /dev/null \
    --write-out '%{url_effective}' "$tarball_url")"
if [[ ! "$resolved_url" =~ ^https://releases\.nixos\.org/nixos/[^/]+/nixos-([^/]+)/nixexprs\.tar\.xz$ ]]; then
    echo "channel did not resolve to a NixOS release tarball: $resolved_url" >&2
    exit 1
fi
version="${BASH_REMATCH[1]}"

sha256="$(nix-prefetch-url --unpack "$resolved_url")"
if [[ ! "$sha256" =~ ^[0-9abcdfghijklmnpqrsvwxyz]{52}$ && ! "$sha256" =~ ^sha256-[A-Za-z0-9+/]+={0,2}$ ]]; then
    echo "unexpected hash from nix-prefetch-url: $sha256" >&2
    exit 1
fi

KERNEL_NIXPKGS_VERSION="$version" KERNEL_NIXPKGS_SHA256="$sha256" \
    perl -0pi -e '
      my $version = $ENV{KERNEL_NIXPKGS_VERSION};
      my $sha256 = $ENV{KERNEL_NIXPKGS_SHA256};
      my $count = s{kernelNixpkgsVersion = "[^"]+";\n  kernelNixpkgsSha256 = "[^"]+";}
                    {kernelNixpkgsVersion = "$version";\n  kernelNixpkgsSha256 = "$sha256";};
      die "expected exactly one RT kernel pin, replaced $count\n" unless $count == 1;
    ' "$config_file"

echo "Pinned the RT kernel to NixOS $version."
