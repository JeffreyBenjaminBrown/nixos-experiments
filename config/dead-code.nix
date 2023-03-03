# from configuration.nix

{ config, pkgs, ... }:

{

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  hardware.pulseaudio.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

}

# from packages.nix

{ config, pkgs, nixpkgs, ... }:

{
  environment.systemPackages =
    with pkgs;
    let
      # TODO | PITFALL : These definitions are, so far, unused.
      # They might let me make the config cleaner. Specifically,
      # I could substitute python-with-my-packages (defined here)
      # for python3 in environment.systemPackages,
      # and then delete a lot of python310Packages.* declarations,
      # and also move the Python list to a separate file.
      # That would not be equivalent to this current config,
      # because I declare more Python libraries in my-python-packages
      # than I declare outside of it.
      my-python-packages = python-packages: with python-packages; [
        # Things NixOS won't install.
        # coconut[mypy]
        # csv-diff
        # django-stubs    # Maybe django is (now) enough?
        # pandas-stubs
        # pydotplus       # Maybe pydot is enough?
        # surbtc          # Phanaeros needs this.
        # weightedcalcs   # Phanaeros needs this.
        # yahoofinancials # Phanaeros needs this.
        awscli
        libpst
        coconut
        django
        google-api-python-client
        google-auth-oauthlib
        graphviz
        icecream
        mypy
        numpy
        openpyxl
        pandas
        pip
        psutil
        pydot
        pytest
        requests
        setuptools
        types-requests
        typing
        virtualenv
        wheel
        yfinance
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in [

      ### printer ###
      ###############
      # hplip # Drivers for HP printers, scanners, fax machines
              # Worthless (tried it for my worthless HP Deskjet 1112,
              # which was not recognized).

      # cachix # CL client for Nix binary cache hosting. https://cachix.org
      #        # Used by Karya.

      # (texlive.combine { inherit (texlive)
      #   scheme-small
      #   latexmk
      #   bibtex; }) #for pdflatex

      # samsung-UnifiedLinuxDriver
        # to connect phone to computer, hopefully,
        # but I suspect it's just for pinters, not phone.
        # After installing it I still couldn't connect my M-31.

      # Java
        # gradle_4_10 # Builds Java code. Used by SmSn.
        #             # The latest one, 5.6.1, is just called "gradle".
        #             # I'm using 4 because SmSn won't build with gradle 5.
        # maven # a build tool

      # ponyc # like Erlang but with stricter typing, maybe?

      # spago # a PureScript build tool.
              # Broke on nixpks unstable after nixpkgs 21.11

      # haskellPackages.hasktorch
        # Can't build, because the backprop package is marked as broken.

      # Didn't work. Installed instead by ./imperative.sh
        # haskellPackages.vivid
        # haskellPackages.vivid-supercollider
        # haskellPackages.vivid-osc

      # scala
        # scala
        # sbt   # scala build tool

      # Image to text.
        # tesseract4 # Google OCR. Too huge to keep.
        # ocrad # Gnu OCR. Too huge to keep.
        # tabula # extract tables from PDFs

      # qscreenshot        # shows up as a KDE menu widget
        # Not needed -- I've already got Spectacle installed (presss Print).

      # eternal-terminal # Better than Mosh, but
                         # the server doesn't work on Amazon Linux.
      # mosh # An ssh connection robust to interruptions, but
             # the server doesn't work on Amazon Linux.

      # skypeforlinux
      # teams
      # zoom-us

      # vscode   # This or vscodium might be needed for wagsi
      # vscodium # This or vscode   might be needed for wagsi

      # infamousPlugins # broke Feb 2023, never used to my knowledge
