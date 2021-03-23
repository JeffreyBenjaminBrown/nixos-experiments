Asking here:

https://discourse.nixos.org/t/nixos-rebuild-no-longer-finds-the-intero-package-for-emacs/11543

===================

# nixos-rebuild no longer finds the Intero Emacs package.

I recently became unable to build a configuration that used to work.
It began giving me this error:

```
[jeff@jbb-dell:~/nix/jbb-config]$ sudo nixos-rebuild switch
unpacking 'https://github.com/nix-community/emacs-overlay/archive/master.tar.g
z'...
building Nix...
building the system configuration...
error: undefined variable 'intero' at /etc/nixos/emacs.nix:24:7
(use '--show-trace' to show detailed location information)
```

Searching https://search.nixos.org/packages for Intero,
I find `emacs26Packages.intero`, which has the name `emacs-intero`.
I tried replacing `intero` with `emacs-intero`,
and even with `emacs26Packages.intero`, but it didn't work.

I think the problem might be that I'm using Emacs 27.1.
Here's [my Emacs configuration](https://github.com/JeffreyBenjaminBrown/nixos-experiments/blob/393958bbf65dff05763319e056802e8effaafaf9/emacs.nix). Here's the [top level of my configuration](https://github.com/JeffreyBenjaminBrown/nixos-experiments/blob/393958bbf65dff05763319e056802e8effaafaf9/packages.nix), which includes the following Emacs overlay:
```
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];
```

But I've had that since November, and had the config rebuilding nightly throughout all of January without incident. I don't understand the overlay (or overlays generally). I think I copied it from Jethro Kuan, creator of `org-roam`, as a way to make sure things were sufficiently up to date that org-roam would work.

For now I've just deleted it from my config.

If I want it to work again, will I have to build an Intero package for Emacs 27 Or is that a red herring, and if so, how can I restore Intero?
