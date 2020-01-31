# PITFALL: Depends on libmonome, which is available from this repo, or from
# [my fork of nixpkgs](https://github.com/JeffreyBenjaminBrown/nixpkgs),
# but which is not yet part of the nixpkgs master branch.

# Built with sagacious help from Robert Kovacsics (@KoviRobi):
# https://discourse.nixos.org/t/nix-build-fails-because-python-wants-something-thats-unavailable-without-saying-what-it-wants/5675/4

{ stdenv, libmonome, liblo, fetchgit, python3, wafHook, libudev, udev, systemd, avahi-compat, avahi }:

stdenv.mkDerivation rec {
  name = "serialosc";
  version = "v1.4.1";

  src = fetchgit {
    url = https://github.com/monome/serialosc;
    rev = "cec0ea76b2d5f69afa74d3ffc14a0950e32a7914";
    # date: "2019-06-09T21:46:13+02:00"
    sha256 = "03qkzslhih72idwafgfxmkwp5v3x048njh0c682phw2ks11plmbp";
    fetchSubmodules = true;
  };

  patches = ./fix-git-commit-in-wscript.patch;

  # The"LIBUV"  error message suggested this.
  # It causes more details to be reported upon failure.
  wafFlags = ["-v"];

  nativeBuildInputs = [ wafHook ];
  buildInputs = [
    avahi
    avahi-compat
    liblo
    libmonome
    libudev
    libudev
    python3
    systemd
    udev
  ];
}
