{...}:

with (import <nixpkgs> {});
derivation {
  name = "hello-fetch";
  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];
  buildInputs = [ gnutar gzip gnumake gcc binutils-unwrapped coreutils gawk gnused gnugrep ];
  src = fetchurl{
    url = http://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz;
    sha256 = "31e066137a962676e89f69d1b65382de95a7ef7d914b8cb956f41ea72e0f516b";
  };
  system = builtins.currentSystem;
}
