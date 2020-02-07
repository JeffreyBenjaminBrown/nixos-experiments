# PITFALL: Depends on libmonome, which is available from this repo, or from
# [my fork of nixpkgs](https://github.com/JeffreyBenjaminBrown/nixpkgs),
# but which is not yet part of the nixpkgs master branch.

# Built with sagacious help from Robert Kovacsics (@KoviRobi):
# https://discourse.nixos.org/t/nix-build-fails-because-python-wants-something-thats-unavailable-without-saying-what-it-wants/5675/4

{ stdenv, libmonome, liblo, fetchgit, python3, wafHook, libudev, udev, systemd, avahi-compat, avahi
  #, git, less
, libuv
}:

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

  patches = ./git-commit-in-wscript.patch;

  # The"LIBUV"  error message suggested this.
  # It causes more details to be reported upon failure.
  wafFlags = [ "-v" ];

  # @simonvanderveldt suggested this, here:
  # https://github.com/monome/serialosc/issues/49#issuecomment-583134920
  # As of libuv 1.34.1 (which is on the nixpkgs master branch,
  # but the default nixpkgs used by nix-rebuild is 1.34.0),
  # the `packed-address` warning that was breaking the build is suppressed.
  wafConfigureFlags = [ "--enable-system-libuv" ];

  nativeBuildInputs = [ wafHook ];
  buildInputs = [
    avahi
    avahi-compat
    liblo
    libmonome
    libudev
    python3
    systemd
    udev
    libuv
#    git less # for debugging
  ];
}
