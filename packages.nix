{ config, pkgs, nixpkgs, ... }:

{
  environment.systemPackages =
  with pkgs; [
    ### editors ###
    ###############
    (import ./emacs.nix { inherit pkgs; })
      # Fun fact: Does not rely on the `with pkgs` statement.
    mg

    ### for monome ##
    #################
    systemd      # for libudev
    udev         # for libudev
    avahi        # for libavahi-compat-libdnssd-dev
    avahi-compat # for libavahi-compat-libdnssd-dev

    ### storage, versioning, formatting ###
    #######################################
    ntfs3g # NTFS driver (e.g. for Windows hard drives)
    archiver
    zip
    unzip
    gzip
    gitMinimal
    nix-prefetch-git # to compute "the" sha256 of a git repo
    ark
    borgbackup
    encfs
    pandoc
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

    ### build tools ###
    ###################
    # waf # broken -- builds to a file, not a folder
          # see my issues on StackOverflow
    wafHook

    ### networking, trafficking ###
    ###############################
    networkmanager
    plasma-nm
    rtorrent
    wget
    signal-desktop
    tdesktop # telegram

    ### exploring filetree ###
    ##########################
    tree
    file # shows types of files
    libsForQt5.dolphin
    agrep # fuzzy search!
    ripgrep

    ### explore system ##
    #####################
    dmidecode # to learn about system RAM
    i2c-tools # includes decode-dimms
    pciutils # for lspci, to learn about sound card, per musnix readme

    ### programming languages, or close neighbors ###
    #################################################
    awscli
    docker
    docker-compose
    # Java
      # gradle_4_10 # Builds Java code. Used by SmSn.
      #             # The latest one, 5.6.1, is just called "gradle".
      #             # I'm using 4 because SmSn won't build with gradle 5.
      # maven # a build tool
    python
    python3
    gcc
    memcached    # Requirement for Agora.
    libmemcached # C/C++ library. Requirement for Agora.
    stack
    ghc
    # I hoped these next two would let me build a new Stack project
    # (stack new, cd, stack build) but I still get the error
    # "libffi.so.6: cannot open shared object file: No such file or directory"
    haskellPackages.libffi
    libffi
    haskellPackages.hasktags
    # haskellPackages.tidal # Broken.
    haskellPackages.jack
    jack2
    haskellPackages.SDL  # a sound library
    haskellPackages.sdl2 # another version of that
    #haskellPackages.vivid  # marked as broken; Nix refuses to evaluate
    #haskellPackages.vivid-supercollider
    #haskellPackages.vivid-osc
    # scala
      # scala
      # sbt   # scala build tool
    sqlite

    ### photo|video ###
    ###################
    # Image to text.
      # tesseract4 # Google OCR. Too huge to keep.
      # ocrad # Gnu OCR. Too huge to keep.
      # tabula # extract tables from PDFs
    gnumake
    gimp         # manipulate images
    ghostscript  # manipulate images
    imagemagick7 # manipulate images
    kdenlive     # video editor
      ffmpeg-full  # video tools, not required by kdenlive but recommended
    pdftk        # manipulate pdfs
    libsForQt5.okular
    vlc
    capture              # screen capture (video, I think)
    qscreenshot          # shows up as a KDE menu widget
    screenkey            # show what I'm typing on the screen
    lsof # for testing pulse audio, per https://nixos.wiki/wiki/PulseAudio
    simplescreenrecorder # includes mic input
    gnome.cheese

    ### misc ###
    ############
    aspell aspellDicts.en aspellDicts.es
    killall
    xsel
    gnumeric
    tmux

    ### big | sketchy | unfree ###
    ##############################
    libreoffice
    firefox
    brave
    google-chrome
    teams
    # skypeforlinux
    # zoom-us

    #### audio, important ###
    #########################
    a2jmidid
    ardour
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
    supercollider
    supercollider_scel
    vmpk # virtual MIDI keyboard

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
    QmidiNet # "a midi network gateway"
  ];
}
