{...}:

with (import <nixpkgs> {});
derivation {
  name = "libmonome";
  builder = "${bash}/bin/bash";
  args = [ ./builder.sh ];
  buildInputs = [ git
                  coreutils
                  liblo
                  python2
                ];
  # I would like to use fetchGit but haven't gotten it to work.
  # src = fetchGit {
  #   url = "https://github.com/monome/libmonome.git";
  # };
  repo = ./libmonome;
  system = builtins.currentSystem;
}
