{ pkgs, ... }:

{
  environment.systemPackages =
    with pkgs; [

      ### editors ###
      ###############
      (import ./emacs.nix { inherit pkgs; })
        # Fun fact: Does not rely on the `with pkgs` statement.
      mg

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
      ark
      borgbackup
      rclone # sync a clone to a (big commercial) cloud
      encfs
      pandoc
      dos2unix
      corefonts # to build Mikhal's code, which hasn't worked yet
      lmodern # pandoc needs this to convert .md to .pdf
      mtools # For `mlabel`, for relabeling a drive
      diff-so-fancy

      ### build tools ###
      ###################
      gnumake
      cmake

      ### networking, trafficking ###
      ###############################
      element-desktop # for Matrix.org
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
      exiftool
      file # shows types of files
      go-mtpfs # to mount Android filesystem
      libsForQt5.dolphin # A             file manager.
      lxqt.pcmanfm-qt    # A lightweight file manager with eject buttons.
      agrep # fuzzy search!
      ripgrep # "rg"
      psmisc # Tools that use the proc filesystem,
             # including fuser, killall, pstree.

      ### explore system ##
      #####################
      cpufrequtils
      pkg-config # lets packages know things about other packages
      dmidecode # to learn about system RAM
      i2c-tools # includes decode-dimms
      pciutils # for lspci, to learn about sound card, per musnix readme
      xorg.xev # to view keycodes corresponding keyboard keys
      xorg.xmodmap # to remap keycodes (in ~/.xmodmap)

      ### programming languages, or close neighbors ###
      #################################################
      awscli
      calc
      docker
      docker-compose
      libcgroup # control the CPU consumption of process hierarchies
      nushell
      libnotify # I use this for the `notify-send` command.

      # to build thumbkey (Android keyboard)
      #
      # gradle
      # kotlin  # Compiles to java, javascript, or native binary (many OSs).
      # android-studio
      # androidenv.androidPkgs_9_0.androidsdk

      erlang
      perl  # Perl 5, required by the Emacs `erlang` package
      jq

        ### Python \ programming languages ###
        ######################################
        python3

        # Some especially ornery or critical Python packages,
        # for which either I was unable to install via virtualenv,
        # or I thought it would be a bad idea.
        python310Packages.pytest
        python310Packages.mypy
        python310Packages.numpy
        python310Packages.pandas
        python310Packages.pip
        python310Packages.setuptools
        python310Packages.wheel
        python310Packages.torch
        virtualenv
        coconut

      gcc
      glibc
      go           # aka golang
      memcached    # Requirement for Agora.
      libmemcached # C/C++ library. Requirement for Agora.
      libssh2      # a C library needed by Lumatone
      purescript
      nodejs-18_x
      nodePackages.typescript

      ghc
      cabal-install

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
      sqlite
      zsh

      ### graphics|photo|video ###
      ###################
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
      screenkey            # show what I'm typing on the screen
      lsof # for testing pulse audio, per https://nixos.wiki/wiki/PulseAudio
      simplescreenrecorder # includes mic input
      gnome.cheese

      ### misc ###
      ############
      arianna
      beep # since `tput bel` stopped working
      aspell aspellDicts.en aspellDicts.es
      killall
      xsel
      gnumeric
      tmux
      acpi # show battery status
      gnome.gnome-disk-utility

      ### big | sketchy | unfree ###
      ##############################
      libreoffice-fresh
      unoconv # shell script for converting docs using libreoffice
      firefox
      google-chrome
      spotify

      #### audio, important ###
      #########################
      a2jmidid
      audacity # good for editing samples
      ardour
      reaper
      SDL
      SDL2
      carla
      # jack_capture # record speaker output to file
      qjackctl
      # cadence      # broken because jack_capture is
      flac
      sox
      ladspaH
      faust # for Karya
      supercollider-with-sc3-plugins
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
      # infamousPlugins # broke Feb 2023, never used to my knowledge
      lsp-plugins
      kapitonov-plugins-pack
      magnetophonDSP.pluginUtils
      distrho
      eq10q
      fomp
      tap-plugins
    ];
}
