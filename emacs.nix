# Based on the NixOS manual, section
# 21.1.2. Adding Packages to Emacs
# https://nixos.org/nixos/manual/index.html#module-services-emacs-adding-packages

{ pkgs ? import <nixpkgs> {} }:

let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
    magit          # ; Integrate git <C-x g>
    zerodark-theme # ; Nicolas' theme
  ]) ++ (with epkgs.melpaPackages; [
    python-mode
    haskell-mode
    intero         # for haskell
  ]) ++ (with epkgs.elpaPackages; [
    undo-tree
    org
    auctex         # ; LaTeX mode
  ]) ++ [
    pkgs.notmuch   # elisp-scriptable email
  ])
