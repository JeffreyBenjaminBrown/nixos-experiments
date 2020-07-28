Suddenly I can't rebuild my cconfiguration (this repo).
This branch of this repo is intended to find out why.

# My suspicion

Each time I try to rebuild I get the message `No package 'alsa' found`.
I think that's the error that's killing the build.
And indeed there's no such package in [the nixpkgs repo](https://nixos.org/nixos/packages.html?channel=nixos-20.03&page=2&query=alsa).
Maybe there used to be, but now the closest seems to be `alsaLib`.
I therefore tried adding `alsaLib`, and even `alsa-tools` and `alsa-utils`,
to my configuration, but it didn't help.

I would change a recipe accordingly,
but I don't know which recipe is asking for the nonexistent package.

# I saved some build traces

This folder includes four files that begin with the word "trace".
They show what happens when I try to rebuild my system under different conditions.

For those called "stable-channel", I set the following:
```
sudo nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
sudo nix-channel --add https://nixos.org/channels/nixpkgs-stable nixpkgs
```

For those called "unstable-channel", I used:
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
```

I build using [the Musnix repo](https://github.com/musnix/musnix)
for my audio setup.
In late June I pulled changes from upstream.
Fortunately I can find when I did that by running `git log`:
```
commit 89cf5880a2e32ddc15bf518a79959e873de844be (HEAD -> master)
Merge: ba99f44 8e45db1
Author: JeffreyBenjaminBrown <jeffbrown.the@gmail.com>
Date:   Sat Jun 27 18:52:00 2020 -0500

    Merge branch 'master' of https://github.com/musnix/musnix

commit ba99f444246fc92b665b3489225e9c022998eeae (origin/master, origin/HEAD)
Merge: 292acae e1f6b85
Author: JeffreyBenjaminBrown <jeffbrown.the@gmail.com>
Date:   Mon Jan 13 23:04:33 2020 -0500

    Merge remote-tracking branch 'upstream/master'
```

So the trace files that say "jan-musnix" were what the build produced
while I had checked out the version of the code from January 13 2020,
and the trace files that say "june-musnix" are what the build produced
while I had checked out the version of the code from June 27 2020.
