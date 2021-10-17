# Running this script from this folder will
# copy `default.nix` from here to an appropriate place in my nixpkgs fork.
# In that fork, the file `pkgs/top-level/all-packages.nix`
# will need separate modification.

to_nixpkgs="/home/jeff/nix/nixpkgs-fork"
within_nixpkgs="/pkgs/development/libraries/sc3-plugins"

cp default.nix $to_nixpkgs/$within_nixpkgs
