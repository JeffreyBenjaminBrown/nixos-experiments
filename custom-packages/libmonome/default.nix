# Apes this file from the nixpkgs repo:
# pkgs/tools/networking/weighttp/default.nix

# PITFALL: This won't build from here, but it will from nixpkgs.
# I put it at /pkgs/development/libraries/libmonome,
# and added the line
#     libmonome = callPackage ../development/libraries/libmonome { };
# to
#     ~/nix/nixpkgs/pkgs/top-level/all-packages.nix
# right after liblo (arbitrary but kind of natural).
# Then from the top of nixpkgs, run any of these:
#   `nix-build -A libmonome`
#   `nix-env -f . -iA libmonome`.

# PROBLEM: When the libmonome repo is updated, this will break.
# Will need to change the `sha256` key.

# PROBLEM: Does not seem to have permission to access the monome without sudo:
# [jeff@jbb-dell:~/nix/nixpkgs]$ monomeserial
# libmonome: could not open monome device: Permission denied
# failed to open /dev/ttyUSB0
# [jeff@jbb-dell:~/nix/nixpkgs]$ sudo monomeserial
# [sudo] password for jeff:
# monomeserial version 1.4.2, yay!
# initialized device m0000102 (monome 256) at /dev/ttyUSB0, which is 16x16 using proto
#  mext
# running with prefix /monome
# ^C
# [jeff@jbb-dell:~/nix/nixpkgs]$

# MAYBE A PROBLEM: I've got liblo, not liblo-dev, installed.
# But maybe that distinction matters on Debian and not my system.
# When I view the Debian package:
#   https://packages.debian.org/jessie/liblo-dev
# it looks like all it contains is liblo 7 or 0.28-3:
#   dep: liblo7 (= 0.28-3)
# The "liblo" line in my packages.nix should be installing liblo 0.29:
#   https://nixos.org/nixos/packages.html?channel=nixos-19.03&query=liblo


{ stdenv, libudev, liblo, fetchgit, python3, wafHook}:

stdenv.mkDerivation rec {
  name = "libmonome";
  version = "v1.4.2";

  src = fetchgit {
    url = https://github.com/monome/libmonome.git;
    rev = version;
    # date = 2018-04-30T17:26:39-04:00;
    sha256 = "17g4m17ibpcwyxzh4pqpd7h7xk146ay130jlk3zjjn23fypwahhi";
  };

  nativeBuildInputs = [ wafHook ];
  buildInputs = [
    liblo
    libudev
    python3
  ];
}
