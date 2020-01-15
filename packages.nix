{ config, pkgs, nixpkgs, ... }:

{ environment.systemPackages =
  [ (import ./emacs.nix { inherit pkgs; })
  ] ++ ( with pkgs; [
    # storage, versioning
    archiver
    zip
    unzip
    gzip
    gitMinimal
    ark
    borgbackup
    encfs

    # networking
    networkmanager
    plasma-nm

    # exploring filetree
    tree
    file # shows types of files
    kdeApplications.dolphin-plugins

    # explore system
    dmidecode # to learn about system RAM
    i2c-tools # includes decode-dimms
    pciutils # for lspci, to learn about sound card, per musnix readme

    # programming languages, or close neighbors
    awscli
    docker
    python
    python3
    stack
    ghc
    # I hoped these next two would let me build a new Stack project
    # (stack new, cd, stack build) but I still get the error
    # "libffi.so.6: cannot open shared object file: No such file or directory"
    haskellPackages.libffi
    libffi
    haskellPackages.hasktags
    haskellPackages.tidal
    #haskellPackages.vivid  # marked as broken; Nix refuses to evaluate
    #haskellPackages.vivid-supercollider
    #haskellPackages.vivid-osc
    scala
    sbt   # scala build tool

    gimp         # manipulate images
    ghostscript  # manipulate images
    imagemagick7 # manipulate images
    pdftk        # manipulate pdfs
    kdeApplications.okular
    vlc
    capture     # screen capture (video, I think)
    qscreenshot # shows up as a KDE menu widget

    # misc
    killall
    xsel
    gnumeric
    tmux
    ktorrent

    # big | sketchy | unfree
    libreoffice
    firefox
    brave
    spotify
    google-chrome

    # audio, important
    a2jmidid
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

    # audio, maybe gratuitous, selected from magnetophon's config:
    # https://github.com/magnetophon/nixosConfig
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
  ] ) ;
}