with (import <nixpkgs> {});
derivation {
  name = "hello";
  builder = "${bash}/bin/bash";
  args = [ ./hello_builder.sh ];
  inherit gnutar gzip gnumake gcc coreutils gawk gnused gnugrep;

  # If we were going to write `binutils = binutils`,
  # we could have more briefly included binutils
  # in the preceding `inherit` statement.
  binutils = binutils-unwrapped;

  src = ./hello-2.10.tar.gz;
  system = builtins.currentSystem;
}
