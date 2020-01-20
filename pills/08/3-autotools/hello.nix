let
  pkgs = import <nixpkgs> {};

  # autotools.nix defines a function of two arguments.
  # Here we provide the first argument.
  mkDerivation = import ./autotools.nix pkgs;

in mkDerivation { # and this set is the second
  name = "hello";
  src = ./hello-2.10.tar.gz;
}
