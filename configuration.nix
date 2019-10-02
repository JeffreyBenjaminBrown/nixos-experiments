{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tree
    networkmanager
    plasma-nm
    emacs
    gitMinimal
    gnumeric
    borgbackup
    encfs
    tmux
    ark
    kdeApplications.dolphin-plugins
    kdeApplications.okular
    firefox
    brave
    docker
    dockerTools
    python
    python3
    stack
  ];
  nixpkgs.config.allowUnfree = true; # for Chrome


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

  # Docker
  virtualisation.docker.enable = true;


  ####
  #### Below: Unlikely to change much
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
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Bogota";

  # User accounts.
  # Don't forget to set a password with ‘passwd’.
  users.users.jeff = {
    isNormalUser = true;
    extraGroups = [
      "docker"         # for sudo
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
