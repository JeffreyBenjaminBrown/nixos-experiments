{ config, pkgs, nixpkgs, ... }:

{
  environment.systemPackages =
    [ (import /etc/nixos/emacs.nix { inherit pkgs; }) ] ++
    (with pkgs; [
      tree
      file
      networkmanager
      plasma-nm
      gitMinimal
      gnumeric
      borgbackup
      encfs
      tmux
      ark
      kdeApplications.dolphin-plugins
      kdeApplications.okular

      docker
      python
      python3
      stack
      ghc

      # mammoths
      libreoffice
      firefox
      brave
      spotify
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

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

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

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Boot loader
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/sda";

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
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"          # for sudo
      "networkmanager" # for the plasma-nm widget
      "audio"
      ];
  };

  # PITFALL: To avoid breaking some software,
  # change this only when NixOS release notes say.
  system.stateVersion = "19.03";
    # PITFALL: read preceding comment.
}
