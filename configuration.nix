{ config, pkgs, nixpkgs, ... }:

{
  environment.systemPackages =
    [ (import /etc/nixos/emacs.nix { inherit pkgs; })
    ] ++
    (with pkgs; [
      archiver
      zip
      unzip
      gzip

      tree
      file
      killall
      xsel
      networkmanager
      plasma-nm
      gitMinimal
      gnumeric
      borgbackup
      encfs
      tmux
      ark
      kdeApplications.dolphin-plugins
      ktorrent

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

      # big and/or sketchy
      libreoffice
      firefox
      brave
      spotify
      google-chrome
  ]);
  nixpkgs.config.allowUnfree = true; # for Spotify, maybe Chrome

  virtualisation.docker.enable = true;


  ####
  #### Below: Unlikely to change much
  ####

  # Networking

    networking.hostName = "jbb-dell"; # Define your hostname.
    networking.networkmanager.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;


  # Devices

    # to read ExFat (which the blue matchbox uses)
    boot.extraModulePackages = [
      config.boot.kernelPackages.exfat-nofuse ];

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.gutenprint
                                  pkgs.gutenprintBin
                                  pkgs.hplip
                                  pkgs.hplipWithPlugin ];

    sound.enable = true;

    # This is based on the JACK section of the NixOS WIKI.
    # If I comment out this whole services.jack section,
    # Youtube becomes audible in Brave and Chrome.
    # If I uncomment it, rebuild, and reboot, Youtube is no longer audible.
    #services.jack = {
      #  # REFERENCE: https://nixos.wiki/wiki/JACK
      #  # This passage is copied from the first section.
      #  # After that there's a warning that "this section is obsolete";
      #  # I haven't tried most of what's listed thereafter.
      #  # (I did try configuring Qjackctl as described in that obsolete section,
      #  # and the instructions were inapplicable to my version of it (0.5.9).
      #  jackd.enable = true;
      #  # support ALSA only programs via ALSA JACK PCM plugin
      #  alsa.enable = false;
      #  # support ALSA only programs via loopback device (supports programs like Steam)
      #  loopback = {
      #    enable = true;
      #    # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
      #    dmixConfig = ''period_size 2048'';
      #  };
      #};

    # Enable touchpad support.
    services.xserver.libinput.enable = true;


  # UI

    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "eurosign:e";

    # Enable the KDE Desktop Environment.
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;


  ####
  #### Below: Even less likely to change much
  ####

  system.autoUpgrade.enable = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./audio.nix
    ];

  # Boot loader
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda"; };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8"; # I've tried this both as
      # English and Spanish. Presumably the next option,
      # extraLocaleSettings, is more important.
    extraLocaleSettings = {
      # These are copied near-verbatim from my work system
      # (KUbuntu 18.04), except with more quotation marks
      # (it used them for English but not Spanish),
      # and space around the equals signs.
      # Most of them are Colombian Spanish; exceptions are noted.
      LANG              = "en_US.UTF-8"; # English
      # LANGUAGE=   # The Ubuntu system shows "LANGUAGE="
                    # when I evaluate `locale`.
      LC_CTYPE          = "en_US.UTF-8"; # English
      LC_NUMERIC        = "es_CO.UTF-8";
      LC_TIME           = "es_CO.UTF-8";
      LC_COLLATE        = "en_US.UTF-8"; # English
      LC_MONETARY       = "es_CO.UTF-8";
      LC_MESSAGES       = "en_US.UTF-8"; # English
      LC_PAPER          = "es_CO.UTF-8";
      LC_NAME           = "es_CO.UTF-8";
      LC_ADDRESS        = "es_CO.UTF-8";
      LC_TELEPHONE      = "es_CO.UTF-8";
      LC_MEASUREMENT    = "es_CO.UTF-8";
      LC_IDENTIFICATION = "es_CO.UTF-8";
      # LC_ALL = # The Ubuntu system shows "LANGUAGE="
                 # when I evaluate `locale`.
    };
  };

  time.timeZone = "America/Bogota";

  # User accounts.
  # Don't forget to set a password with ‘passwd’.
  users.users.jeff = {
    uid = 1000;        # for compatibility with Ubuntu
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"          # for sudo
      "networkmanager" # for the plasma-nm widget, and
        # the privilege of changing settings (adding networks)
      "audio"
      "jackaudio"
      ];
  };

  # PITFALL: To avoid breaking some software,
  # change this only when NixOS release notes say.
  # PITFALL: Surprisingly, it does not have to match the version of
  # NixOS you are running -- for instance, the release notes for 19.09
  # (https://nixos.org/nixos/manual/release-notes.html#sec-release-19.09)
  # state, "When upgrading from NixOS 19.03, please make sure that system.stateVersion is set to "19.03", or lower if the installation dates back to an earlier version of NixOS."
  system.stateVersion = "19.03";
    # PITFALL: read preceding comment.
}
