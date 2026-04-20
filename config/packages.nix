{ pkgs, ... }:

{
  environment.systemPackages =
    with pkgs; [

      ### editors ###
      ###############
      (import ./emacs.nix { inherit pkgs; })
        # Fun fact: Does not rely on the `with pkgs` statement.
      mg

      ### storage, versioning, formatting ###
      #######################################
      smartmontools # to monitor disks' health
      parted
      gparted
      ntfs3g # NTFS driver (e.g. for Windows hard drives)
      # archiver # Marked as insecure as of 2025-01-19.
      zip
      p7zip
      unrar
      unzip
      gzip
      gnupg # to encrypt, decrypt
      pinentry-curses # gnupg needs *some* pinentry. Trying this one.
      gitMinimal
      nix-prefetch-git # to compute "the" sha256 of a git repo
      nixos-option
      kdePackages.ark
      borgbackup
      rclone # sync a clone to a (big commercial) cloud
      encfs
      dos2unix
      pandoc
      corefonts # to build Mikhal's code, which hasn't worked yet
      groff # pandoc said it needs this to convert .md to .pdf
      lmodern      # pandoc said it needs this for the same reason
      texliveFull
      mtools # For `mlabel`, for relabeling a drive
      diff-so-fancy

      ### build tools ###
      ###################
      gnumake
      cmake

      ### networking, trafficking ###
      ###############################
      # element-desktop # Big. For Matrix.org.
      irssi # IRC client
      networkmanager
      nmap
      kdePackages.plasma-nm
      rtorrent
      wget
      gh # GitHub CLI — PRs, repo sync, etc.
      signal-desktop # Broken on 25.05-stable.
      #   Was fixed recently here:
      #   https://github.com/nixos/nixpkgs/issues/418971
      #   Should emrge to main soon enough.
      #   Meanwhile there's the web browser interface.
      telegram-desktop

      ### exploring filetree ###
      ##########################
      tree
      exiftool
      file # shows types of files
      go-mtpfs # to mount Android filesystem
      kdePackages.dolphin # a file manager
      lxqt.pcmanfm-qt     # a file manager
      # agrep # fuzzy search!
      ripgrep # "rg"
      psmisc # Tools that use the proc filesystem,
             # including fuser, killall, pstree.
      anki-bin

      ### explore system ##
      #####################
      cpufrequtils
      pkg-config # lets packages know things about other packages
      dmidecode # to learn about system RAM
      i2c-tools # includes decode-dimms
      pciutils # for lspci, to learn about sound card, per musnix readme
      xev # to view keycodes corresponding keyboard keys
      xmodmap # to remap keycodes (in ~/.xmodmap)
      xhost # to allow X11 connections (e.g. from Docker)

#      # These are both to read an iPhone. See
#      #   https://nixos.wiki/wiki/IOS
#      libimobiledevice
#      ifuse

      ### programming languages, or close neighbors ###
      #################################################
      vscodium-fhs

      # Dotnet is inevaluable and marked as insecure lately.
      # If I disable only dotnet-sdk, I still get warned about it.
      # If I disable all of the below, I don't.
      # So that might be overkill, but until I need dotnet again,
      # it works.
      #
      # mono       # mono    *also* compiles microsoft stuff.
      # msbuild    # msbuild *also* compiles microsoft stuff.
      # roslyn     # roslyn  *also* compiles microsoft stuff.
      # dotnet-sdk # dotnet  *also* compiles microsoft stuff,

      awscli2                    # AWS
      ssm-session-manager-plugin # AWS
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
        python3Packages.mypy
        python3Packages.numpy
        python3Packages.pandas
        python3Packages.pathspec
        python3Packages.pip
        python3Packages.pygame
        python3Packages.pytest
        python3Packages.setuptools
        python3Packages.wheel
        jupyter # ipython and other stuff
        virtualenv
      # coconut -- Python with pattern matching, laziness, ADTs

      gcc
      glibc
      go           # aka golang
      memcached    # Requirement for Agora.
      libmemcached # C/C++ library. Requirement for Agora.
      libssh2      # a C library needed by Lumatone
      purescript
      # spago # purescript package manager, marked broken
      nodejs_24
      typescript
      esbuild

      # When I disabled ghc, it meant version 9.6.
      # I never tried version 9.8, which has three sub-versions.
      # Instead I skipped straight to 9.10, which only has 1,
      # and therefore might not be stable.
      # If it gives me problems, try backtracking to 9.8.3.
      # (So far all the code I've tried compiles with it.)
      #
      # ghc
      # haskellPackages.ghc_9_10_1 # failed
      haskell.compiler.ghc9102
      cabal-install
      rustup # for rust
      cargo  # for rust

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
      libjack2
      jack-example-tools
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
      pdftk        # manipulate pdfs
      qpdf         # manipulate pdfs
      xournalpp    # manipulate pdfs
      poppler-utils # for pdfunite, among others
      kdePackages.okular
      vlc
      capture              # screen capture (video, I think)
      screenkey            # show what I'm typing on the screen
      lsof # for testing pulse audio, per https://nixos.wiki/wiki/PulseAudio
      obs-studio             # Screen record.
      cheese

      ### misc ###
      ############
      kdePackages.arianna
      beep # since `tput bel` stopped working
      aspell aspellDicts.en aspellDicts.es
      killall
      xsel
      gnumeric
      tmux
      acpi # show battery status
      gnome-disk-utility

      ### big | sketchy | unfree ###
      ##############################
      libreoffice-fresh
      unoconv # shell script for converting docs using libreoffice
      firefox
      google-chrome
      spotify
      winetricks
      wineWow64Packages.staging

      #### audio, important ###
      #########################
      a2jmidid
      audacity # good for editing samples
      # Reaper is wrapped in systemd-run so it gets RT scheduling
      # (LimitRTPRIO=99, LimitMEMLOCK=infinity). On X11, KDE
      # doesn't give launched apps these limits otherwise.
      # The desktop entry overrides the one from the reaper package.
      reaper
      (makeDesktopItem {
        name = "cockos-reaper";  # same name as reaper's own .desktop → overrides it
        desktopName = "REAPER";
        comment = "REAPER Digital Audio Workstation";
        exec = "${writeShellScript "reaper-rt" ''
          ${pkgs.systemd}/bin/systemctl --user reset-failed reaper-rt.service 2>/dev/null || true
          exec ${pkgs.systemd}/bin/systemd-run \
            --user --unit=reaper-rt \
            --service-type=exec --collect \
            -p LimitRTPRIO=99 \
            -p LimitMEMLOCK=infinity \
            -E DISPLAY="$DISPLAY" \
            -E XAUTHORITY="$XAUTHORITY" \
            -E XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
            -E DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
            -E HOME="$HOME" \
            ${pkgs.reaper}/bin/reaper "$@"
        ''} %U";
        icon = "cockos-reaper";
        categories = [ "AudioVideo" "Audio" ];
        mimeTypes = [ "application/x-reaper-project" ];
      })
      SDL
      SDL2
      # carla # broken as of <2025-08-31 Sun>
      # jack_capture # record speaker output to file
      qjackctl
      # cadence      # broken because jack_capture is
      flac
      sox
      ladspa-header
      faust # for Karya
      supercollider-with-sc3-plugins
      vmpk # virtual MIDI keyboard
      # yabridge # run VSTs from Wine in a Linux-native VST host
      yabridgectl

      #### Audio
      alsa-utils
      fftw           #            Needed for sc3-plugins.
      fftwFloat      # Maybe also needed for sc3-plugins?
      fftwLongDouble # Maybe also needed for sc3-plugins?
      # vscode   # This or vscodium might be needed for wagsi
      # vscodium # This or vscode   might be needed for wagsi

      (symlinkJoin {

        name = "jbb-plugins";
        paths = [
          drumgizmo
          ffmpeg

          #### Below:                                       ########
          ####   audio, maybe gratuitous,                   ########
          ####   selected from magnetophon's config:        ########
          ####   https://github.com/magnetophon/nixosConfig ########
          ##########################################################

          jack_oscrolloscope
          jackmeter
          jalv
          lilv
          liblo
          graphviz # why is this here?
          jaaa # signal analyzer
          japa # psychoacoustic signal analyzer
          sooperlooper
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
          # kapitonov-plugins-pack  # broke Sept 2025, never used to my knowledge
          magnetophonDSP.pluginUtils
          # eq10q  # broke Oct 2025, and never used to my knowledge
          fomp
          tap-plugins
        ];
      })
    ];
}
