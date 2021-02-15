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
