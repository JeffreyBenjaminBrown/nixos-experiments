# Serialosc and monomeserial for Nix (and NixOS)


## How to use them, once they are installed

Run `serialoscd` from the command line.


## How to install them

This README file is in a folder together with a file called `monome-for-nixpkgs.diff`.

Clone the `nixpkgs` repository:
```bash
git clone https://github.com/NixOS/nixpkgs.git
```

Copy `monome-for-nixpkgs.diff` to the root of the `nixpkgs` folder. From that root folder, apply the diff:
```bash
git apply monome-for-nixpkgs.diff
```

Last, from the same place, install `serialosc` and `monomeserial`:
```bash
nix-env -f . -iA serialosc
nix-env -f . -iA libmonome
```


## What that does

It copies the `libmonome` and `serialosc` Nix derivations found [here](https://github.com/JeffreyBenjaminBrown/nixos-experiments/tree/master/custom-packages/_done) to your `nixpkgs` clone, and also adds a couple lines to `top-level/all-packages.nix` that explain where they are found.

The `.diff` file was created by performing the above changes in `nixpkgs` on a branch called (say) `monome-branch`, and then running `git diff master monome-branch`.


## Plans for the future

Ideally, in order to install something in Nix, you're not supposed to need to "do" anything beyond writing the package's name in your `configuration.nix` file. If ever these `libmonome` and `serialosc` packages are accepted into the official `nixpkgs` repo, it will be like that.
