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

      ### editors ###
      ###############
      (import ./emacs.nix { inherit pkgs; })
        # Fun fact: Does not rely on the `with pkgs` statement.
      mg

      ### printer ###
      ###############
      # hplip # Drivers for HP printers, scanners, fax machines
              # Worthless (tried it for my worthless HP Deskjet 1112,
              # which was not recognized).

      ### for monome ###
      ##################
      systemd      # for libudev
      udev         # for libudev
      avahi        # for libavahi-compat-libdnssd-dev
      avahi-compat # for libavahi-compat-libdnssd-dev

      ### storage, versioning, formatting ###
      #######################################
      smartmontools # to monitor disks' health
      parted
      gparted
      ntfs3g # NTFS driver (e.g. for Windows hard drives)
      archiver
      zip
      p7zip
      unrar
      unzip
      gzip
      gnupg # to encrypt, decrypt
      pinentry # needed by gnupg
      gitMinimal
      nix-prefetch-git # to compute "the" sha256 of a git repo
      nixos-option
      # cachix # CL client for Nix binary cache hosting. https://cachix.org
      #        # Used by Karya.
      ark
      borgbackup
      rclone # sync a clone to a (big commercial) cloud
      encfs
      pandoc
      dos2unix
      corefonts # to build Mikhal's code, which hasn't worked yet
      # (texlive.combine { inherit (texlive)
      #   scheme-small
      #   latexmk
      #   bibtex; }) #for pdflatex
      lmodern # pandoc needs this to convert .md to .pdf
      # samsung-UnifiedLinuxDriver
        # to connect phone to computer, hopefully,
        # but I suspect it's just for pinters, not phone.
        # After installing it I still couldn't connect my M-31.
      mtools # For `mlabel`, for relabeling a drive
      diff-so-fancy

      ### build tools ###
      ###################
      gnumake
      cmake

      ### networking, trafficking ###
      ###############################
      networkmanager
      nmap
      plasma-nm
      rtorrent
      wget
      signal-desktop
      tdesktop # telegram

      ### exploring filetree ###
      ##########################
      tree
      file # shows types of files
      libsForQt5.dolphin # A             file manager.
      lxqt.pcmanfm-qt    # A lightweight file manager with eject buttons.
      agrep # fuzzy search!
      ripgrep # "rg"
      psmisc # Tools that use the proc filesystem,
             # including fuser, killall, pstree.

      ### explore system ##
      #####################
      pkg-config # lets packages know things about other packages
      dmidecode # to learn about system RAM
      i2c-tools # includes decode-dimms
      pciutils # for lspci, to learn about sound card, per musnix readme

      ### programming languages, or close neighbors ###
      #################################################
      awscli
      docker
      docker-compose
      steam-run # To run standalone binaries, e.g. Lumatone Editor

      # Java
        # gradle_4_10 # Builds Java code. Used by SmSn.
        #             # The latest one, 5.6.1, is just called "gradle".
        #             # I'm using 4 because SmSn won't build with gradle 5.
        # maven # a build tool
      erlang
      perl  # Perl 5, required by the Emacs `erlang` package
      jq

    # ponyc # like Erlang but with stricter typing, maybe?

        ### Python \ programming languages ###
        ######################################
        python
        python3

        # Some especially ornery or critical Python packages,
        # for which either I was unable to install via virtualenv,
        # or I thought it would be a bad idea.
        python310Packages.mypy
        python310Packages.numpy
        python310Packages.pandas
        python310Packages.pip
        python310Packages.setuptools
        python310Packages.wheel
        virtualenv
        coconut

      gcc
      glibc
      go_1_17 # aka golang
      memcached    # Requirement for Agora.
      libmemcached # C/C++ library. Requirement for Agora.
      libssh2      # a C library needed by Lumatone
      purescript
      # spago # a PureScript build tool.
              # Broke on nixpks unstable after nixpkgs 21.11
      nodejs-18_x

      ghc
      cabal-install

      darcs
      zlib
      zlib.dev
      haskellPackages.zlib # Needed by Hackage's AWS lib, I guess?

      # I hoped these next two would let me build a new Stack project
      # (stack new, cd, stack build) but I still get the error
      # "libffi.so.6: cannot open shared object file: No such file or directory"
      haskellPackages.libffi
      haskellPackages.HUnit
      libffi
      haskellPackages.hasktags
      haskellPackages.jack
      jack2
      haskellPackages.SDL  # a sound library
      haskellPackages.sdl2 # another version of that

      # Didn't work. Installed instead by ./imperative.sh
        # haskellPackages.vivid
        # haskellPackages.vivid-supercollider
        # haskellPackages.vivid-osc

      # scala
        # scala
        # sbt   # scala build tool
      sqlite
      zsh

      ### graphics|photo|video ###
      ###################
      # Image to text.
        # tesseract4 # Google OCR. Too huge to keep.
        # ocrad # Gnu OCR. Too huge to keep.
        # tabula # extract tables from PDFs
      xdotool      # "fakes keyboard and mouse input, among other things"
      gimp         # manipulate images
      ghostscript  # manipulate images
      imagemagick  # manipulate images
      kdenlive     # video editor
      ffmpeg-full  # video tools, not required by kdenlive but recommended
      pdftk        # manipulate pdfs
      qpdf         # manipulate pdfs
      poppler_utils # for pdfunite, among others
      libsForQt5.okular
      vlc
      capture              # screen capture (video, I think)
      # qscreenshot        # shows up as a KDE menu widget
        # Not needed -- I've already got Spectacle installed (presss Print).
      screenkey            # show what I'm typing on the screen
      lsof # for testing pulse audio, per https://nixos.wiki/wiki/PulseAudio
      simplescreenrecorder # includes mic input
      gnome.cheese

      ### misc ###
      ############
      beep # since `tput bel` stopped working
      aspell aspellDicts.en aspellDicts.es
      killall
      xsel
      gnumeric
      tmux
      acpi # show battery status
      gnome.gnome-disk-utility
      # eternal-terminal # Better than Mosh, but
                         # the server doesn't work on Amazon Linux.
      # mosh # An ssh connection robust to interruptions, but
             # the server doesn't work on Amazon Linux.

      ### big | sketchy | unfree ###
      ##############################
      libreoffice
      firefox
      brave
      google-chrome
      spotify
      # skypeforlinux
      # teams
      # zoom-us

      #### audio, important ###
      #########################
      a2jmidid
      ardour
      reaper
      SDL
      SDL2
      carla
      jack2Full
      jack_capture
      qjackctl
      cadence
      flac
      sox
      ladspaH
      faust # for Karya
      supercollider
      supercollider_scel
      vmpk # virtual MIDI keyboard

      #### Audio
      fftw           #            Needed for sc3-plugins.
      fftwFloat      # Maybe also needed for sc3-plugins?
      fftwLongDouble # Maybe also needed for sc3-plugins?
      # vscode   # This or vscodium might be needed for wagsi
      # vscodium # This or vscode   might be needed for wagsi

      #### audio, maybe gratuitous, selected from magnetophon's config: ###
      #### https://github.com/magnetophon/nixosConfig ######################
      #####################################################################
      jack_oscrolloscope
      jackmeter
      jalv
      lilv
      liblo
      graphviz # why is this here?
      jaaa # signal analyzer
      japa # psychoacoustic signal analyzer
      sooperlooper
      squishyball # for A/B testing. Not clearly audio software.
      shntool # view and modify WAVE files
      x42-plugins # level meters
      ladspa-sdk
      qmidinet # "a midi network gateway"

      # some LV2 plugins (e.g. guitar effects)
      gxplugins-lv2
      swh_lv2
      mda_lv2
      x42-plugins
      zam-plugins
      infamousPlugins
      lsp-plugins
      kapitonov-plugins-pack
      magnetophonDSP.pluginUtils
      distrho
      eq10q
      fomp
      tap-plugins
    ];
}
