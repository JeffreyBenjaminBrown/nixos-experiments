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
      # erlang # Won't't build; doesn't find Perl 5.
               # I even put a symlink called perl5 in ~/bin/,
               # which is part of my PATH.
               # For now it's installed the normal Emacs way,
               # via `M-x pack-list-pack`
      # visual-fill-column # line wrap at word boundaries
      go-mode
      json-mode
      magit        # ; Integrate git <C-x g>
      use-package
      perspective

    ]) ++ (with epkgs.melpaPackages; [
      nix-mode
      native-complete # Tab-completion in *shell* buffers.

      neotree # wonderful visually branching file navigator
      elpy
      hide-lines
      markdown-mode
      # python-mode # Broke in nixpkgs, so I replaced it with `elpy`.
        # I also asked about that here:
        # https://discourse.nixos.org/t/emacs-python-mode-marked-as-broken-cant-rebuild-nixos-config/12674/2
      haskell-mode
      scala-mode
      psc-ide         # PureScript
      psci            # PureScript repl
      purescript-mode # PureScript

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
      emacsql-sqlite3
      ac-helm # autocomplete with Helm
      helm
      helm-company
      consult # for consult-ripgrep. (Requires ripgrep.)
      deadgrep
      # company-org-roam

    ]) ++ (with epkgs.elpaPackages; [
      csv-mode
      undo-tree
      xclip # for copy-paste from `emacs -nw` (within Bash) to other apps

    ]) ++ [
      pkgs.notmuch # email, scriptable
    ]
  )
