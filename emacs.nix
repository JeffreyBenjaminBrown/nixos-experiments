# Based on the NixOS manual, section
# 21.1.2. Adding Packages to Emacs
# https://nixos.org/nixos/manual/index.html#module-services-emacs-adding-packages

# { pkgs ? import <nixpkgs> {} }:
# { config, pkgs ? import <nixpkgs> {}, lib, options, modulesPath }:

let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (
    with epkgs.melpaStablePackages; [
      hide-lines
      magit        # ; Integrate git <C-x g>
      nix-mode
      use-package

    ]) ++ (with epkgs.melpaPackages; [
      # elpy         # will it conflict with python-mode?
      markdown-mode
      python-mode
      haskell-mode
      scala-mode
      intero       # for haskell

      company

      # org-roam seems to develop too fast for this to work.
      # Instead just install procedurally, with package-list-packages.
      # org-roam
      # company-org-roam

    ]) ++ (with epkgs.elpaPackages; [
      csv-mode
      undo-tree
      org
      auctex       # ; LaTeX mode

    ]) ++ [
      pkgs.notmuch # email, scriptable
    ]
  )
