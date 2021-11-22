# Based on the NixOS manual, section
# 21.1.2. Adding Packages to Emacs
# https://nixos.org/nixos/manual/index.html#module-services-emacs-adding-packages

# PITFALL: If any of these stop working, moving them from the
# epkgs.melpaPackages to the epkgs.melpaStablePackages sections might help
# (that is, of course, if they're available in Melpa Stable).

{ pkgs ? import <nixpkgs> {} }:

let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (
    with epkgs.melpaStablePackages; [
      json-mode
      magit        # ; Integrate git <C-x g>
      nix-mode
      use-package

    ]) ++ (with epkgs.melpaPackages; [
      neotree # wonderful visually branching file navigator
      elpy
      hide-lines
      markdown-mode

      # New (2021-03-23), and (to me) experimental.
      mwim
      block-nav
      linum-relative
      free-keys
      iflipb
      rainbow-delimiters
      goto-last-change
      ctrlf
      ace-window
      beacon
      volatile-highlights
      smart-hungry-delete
      restart-emacs

    ]) ++ (with epkgs.elpaPackages; [
      csv-mode
      undo-tree
      xclip # for copy-paste from `emacs -nw` (within Bash) to other apps

    ])
  )
