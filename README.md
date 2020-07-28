Suddenly I can't rebuild my cconfiguration. This folder includes two files, "trace-stable" and "trace-stable". The first shows what happens if I try to rebuild after configuring my system this way:
```
sudo nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
sudo nix-channel --add https://nixos.org/channels/nixpkgs-stable nixpkgs
```

and the second, this way:
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
```

They only differ on 47 out of 186 lines.
