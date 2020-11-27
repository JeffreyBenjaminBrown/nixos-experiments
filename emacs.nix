# Based on the NixOS manual, section
# 21.1.2. Adding Packages to Emacs
# https://nixos.org/nixos/manual/index.html#module-services-emacs-adding-packages

{ pkgs ? import <nixpkgs> {} }:

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

      # `org-roam` is in Melpa: https://melpa.org/#/org-roam
      # right next to nix-mode: https://melpa.org/#/nix-mode
      # but for some reason this line makes NixOS throw an error:
        # error: undefined variable 'org-roam' at /etc/nixos/emacs.nix:16:7
      org-roam
      # emacsql-sqlite3
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
