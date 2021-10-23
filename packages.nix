{ config, pkgs, nixpkgs, ... }:

{
  environment.systemPackages =
  with pkgs; [
    ### editors ###
    ###############
    (import ./emacs.nix { inherit pkgs; })
      # Fun fact: Does not rely on the `with pkgs` statement.
    mg
    atom # For TidalCycles

    ### for monome ##
    #################
    systemd      # for libudev
    udev         # for libudev
    avahi        # for libavahi-compat-libdnssd-dev
    avahi-compat # for libavahi-compat-libdnssd-dev

    ### storage, versioning, formatting ###
    #######################################
    parted
    ntfs3g # NTFS driver (e.g. for Windows hard drives)
    archiver
    zip
    unzip
    gzip
    gnupg # to encrypt, decrypt
    pinentry # needed by gnupg
    gitMinimal
    nix-prefetch-git # to compute "the" sha256 of a git repo
    cachix # CL client for Nix binary cache hosting. https://cachix.org
           # Used by Karya.
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
    erlang
    perl  # Perl 5, required by the Emacs `erlang` package

    # To get the latest one I'm installing gleam and rebar3
    # "semi-procedurally"
    # from my nixpkgs fork; see org node
    # [[id:c15685f2-54d8-40dd-a49c-d87ec0bd5034][3 - commands to build it]]
      # gleam # like Erlang but with more robust typing
      # rebar3 # A REPL for Gleam

    ponyc # like Erlang but stricter typing, maybe?
    python
    python3
    gcc
    memcached    # Requirement for Agora.
    libmemcached # C/C++ library. Requirement for Agora.
    # haskellPackages.stackage-to-hackage # marked as broken
    purescript
    spago # a PureScript build tool
    haskellPackages.Cabal_3_6_2_0
    cabal-install
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
    zsh

    ### photo|video ###
    ###################
    # Image to text.
      # tesseract4 # Google OCR. Too huge to keep.
      # ocrad # Gnu OCR. Too huge to keep.
      # tabula # extract tables from PDFs
    gnumake
    cmake
    gimp         # manipulate images
    ghostscript  # manipulate images
    imagemagick  # manipulate images
    kdenlive     # video editor
      ffmpeg-full  # video tools, not required by kdenlive but recommended
    pdftk        # manipulate pdfs
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
    faust # for Karya
    supercollider
    supercollider_scel
    vmpk # virtual MIDI keyboard

    #### Audio
    fftw           #            Needed for sc3-plugins.
    fftwFloat      # Maybe also needed for sc3-plugins?
    fftwLongDouble # Maybe also needed for sc3-plugins?
    nodejs-17_x
    vscode # This or vscodium needed for wagsi
    vscodium # This or vscode needed (so far) for wagsi

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
