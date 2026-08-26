# Bump ONLY pipewire + wireplumber to a newer nixpkgs than the rest of the
# system, without touching the realtime kernel.
#
# WHY THIS EXISTS
# ---------------
# The running system is built from an older channel whose pipewire is 1.2.6.
# The Docker dev container (other-projects/docker-typedb-rust) is built from a
# newer `<nixpkgs>` and ships pipewire 1.6.3. A 1.6.3 *client* -- pw-play, the
# beep hook (~/.claude/hooks/beep.sh), and the cpal synths running inside the
# container -- connects to the 1.2.6 host *server* fine for introspection
# (pw-cli/pw-dump work), but the playback path silently stalls:
#
#   stream state changed paused -> streaming
#   stream time: ... ticks:0 ... buffers:0      <- clock never advances
#
# The 1.6 client advertises async-node scheduling (node.async=true) and
# negotiates PeerCapability, which the 1.2.6 server does not drive, so the node
# is added to the graph but never scheduled. pw-play then blocks until its
# timeout and no sound is produced. Bringing the host's pipewire up to (at
# least) the container's version makes client and server match again.
#
# WHY NOT `nix-channel --update`
# ------------------------------
# That also bumps the musnix realtime kernel (see the PITFALL in
# configuration.nix) and triggers a long RT-kernel rebuild. Overriding only
# pipewire + wireplumber from a separate, pinned nixpkgs avoids that: the
# kernel and everything else stay on the current channel.
#
# CHOOSING `ref`
# --------------
# `ref` may be a branch name (tracks "latest" -- refetched per fetchTarball's
# ~1h TTL) or, preferred for reproducibility, a 40-char commit SHA. Either way
# it must point at a nixpkgs that has pipewire >= 1.6.3 (the container's
# version). To pin to exactly what the container uses, set `ref` to the commit
# of the channel you built the image from:
#
#   nix-instantiate --eval -E '(import <nixpkgs> {}).pipewire.version'  # confirm >= 1.6.3
#   git -C /nix/nixpkgs rev-parse HEAD                                  # the commit to paste
#
# No sha256 is needed: the GitHub archive URL is fetched by `ref`, which pins
# the content for a commit SHA.

{ pkgs, ... }:

let
  # A branch tracks latest; replace with a commit SHA to pin exactly.
  ref = "nixos-unstable";

  newpkgs = import
    (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${ref}.tar.gz")
    {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
in {
  # The NixOS pipewire module references these packages by path, so swapping
  # them here re-points the daemon and the session manager without changing the
  # module itself. Pull both from the same pin so they stay matched to each
  # other.
  services.pipewire.package = newpkgs.pipewire;
  services.pipewire.wireplumber.package = newpkgs.wireplumber;

  # NOTE (32-bit): alsa.support32Bit pulls the 32-bit pipewire ALSA plugin from
  # pkgsi686Linux.pipewire, which this override does NOT touch -- it stays on
  # the system channel. Only matters for 32-bit audio clients (e.g. some Steam
  # games); the beep, pw-play, and the synths are all 64-bit. To also bump it,
  # add a nixpkgs.overlays entry replacing pkgsi686Linux.pipewire.
}
