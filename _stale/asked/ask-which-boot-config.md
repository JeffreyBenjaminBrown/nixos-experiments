Asked on reddit:
  https://www.reddit.com/r/NixOS/comments/lknn4k/how_to_know_which_boot_config_i_am_on_why_is_all/

How to know which boot config I am on? Why is "all configurations" on my boot menu incomplete?

====

[Probably unnecessary but my latest config is [here](https://github.com/JeffreyBenjaminBrown/nixos-experiments/blob/7277558768d3bd06e07d416d1021b41893426146/configuration.nix).)

Today I ran this a few times:

`sudo nixos-rebuild switch -p no_rtirq_or_intero_and_musnix_89cf5880`

After the first time, I didn't see it in the boot menu. Moreover I saw nothing listed in the boot menu under "all configurations" with a date later than February 3. (Today is February 15th.) That led me to believe the config was not available -- but maybe it was, under the `default` option.

Then I ran it again, maybe with the `--upgrade` flag also. (Certainly at some point I ran it with that flag.) Now the new config appears in the boot menu with that name (`no_rtirq_or_intero_and_musnix_89cf5880`), but still under "all configurations" there's nothing newer than February 3rd.

When I choose either that named config or the default boot config, I am unable to run commands starting with `intero-` from Emacs. So it would appear that that named build is both my default and the config with that name.

But in future I'd like a more elegant method. Is there to ask NixOS, once you've booted, which configuration you're using?

And why is the list of "all configurations" incomplete?

===

Sweet, thanks!

If you don't mind, please let me know if I'm doing this correctly:

When I run run `stat /run/current-system` the output included (among others) this line:
```
  File: /run/current-system -> /nix/store/fyx0xdx1kakl2vd5jgc3rk8a7a0yq9qz-nixos-system-jbb-dell-20.09.3124.2118cf551b9
```

There exists at least one file in (a subfolder of) `/nix/var/nix/profiles` that links to a folder with the same hash as part of its name:

```
[jeff@jbb-dell:/nix/var/nix/profiles]$ ls system-profiles/ -l
total 12
lrwxrwxrwx 1 root root 36 feb 15 16:57 no_intero_and_musnix_06eaf399 -> no_intero_and_musnix_06eaf399-1-link
lrwxrwxrwx 1 root root 88 feb 15 16:57 no_intero_and_musnix_06eaf399-1-link -> /nix/store/fyx0xdx1kakl2vd5jgc3rk8a7a0yq9qz-nixos-system-jbb-dell-20.09.3124.2118cf551b9
...
```

So at this point I'm already convinced that the current boot config is the one I named `no_intero_and_musnix`. But did you mean for me to go further? I see that if I enter that folder and then execute `nix show-derivation $(pwd)`, it prints out a really hairy expression that begins
```
{
  "/nix/store/pdk7ip7by9siyf4kl4kkj45rv14jx346-nixos-system-jbb-dell-20.09.3124.2118cf551b9.drv": {
    "outputs": {
      "out": {
        "path": "/nix/store/fyx0xdx1kakl2vd5jgc3rk8a7a0yq9qz-nixos-system-jbb-dell-20.09.
3124.2118cf551b9"
      }
    },
    "inputSrcs": [
      "/nix/store/9krlzvny65gdc8s7kpb6lkx8cd02c25b-default-builder.sh",
      "/nix/store/iczcvcwxd9pz9agwci6m1f65aywa2jyi-update-users-groups.pl",
      "/nix/store/isg0z7nm187j389qdd9m1bkjvkncyr2k-switch-to-configuration.pl",
      "/nix/store/vn1xs9s2akf79y1pbya2qldydbf2b22m-setup-etc.pl"
    ],                                                                                       "inputDrvs": {
      "/nix/store/070q81yldbz6pwab6axj0wzrcq94vn8k-perl5.32.0-XML-Parser-2.46.drv
	  ...
```

But I'm not sure what to do with that.
