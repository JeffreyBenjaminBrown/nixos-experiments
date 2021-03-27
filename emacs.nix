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

      # New (2021-03-23), and (to me) experimental.
      mwim
      block-nav
      neotree
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
      multiple-cursors

      dante # for haskell
      #
      # As of 2021-02-15 `intero` doesn't show up.
      # Searching https://search.nixos.org/packages for intero,
      # I find emacs26Packages.intero, which has the name `emacs-intero`.
      # But that doesn't show up either. Nor does emacs26Packages.intero.

      company

      # `org-roam` is in Melpa: https://melpa.org/#/org-roam
      # right next to nix-mode: https://melpa.org/#/nix-mode
      # but for some reason this line makes NixOS throw an error:
        # error: undefined variable 'org-roam' at /etc/nixos/emacs.nix:16:7
      org-roam
      consult # for consult-ripgrep. (Requires ripgrep.)
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
