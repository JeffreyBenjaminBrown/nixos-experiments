{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];
p
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./audio.nix
      ./packages.nix
    ];

  environment.variables = # customize Bash (and other stuff?)
    { EDITOR = "mg"; };

  nixpkgs.config.allowUnfree = true; # for Spotify, maybe Chrome
  virtualisation.docker.enable = true;
  environment.homeBinInPath = true; # that is, ~/bin

  networking.hostName = "jbb-dell";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  services.printing.enable = true; # Enable CUPS

  # Enable sound
  sound.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
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

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bogota";

  # User accounts.
  # TODO : Don't forget to set a password with ‘passwd’.
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
      "dialout" # to use the monome without root privileges
      ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  #   firefox
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      devices = ["/dev/sda"]; # Where to put GRUB. "nodev" means EFI only.
    };
  };

  # PITFALL: To avoid catastrophe,
  # change this only when NixOS release notes indicate.
  # PITFALL: Surprisingly, it does not have to match the version of
  # NixOS you are running -- for instance, the release notes for 19.09
  # (https://nixos.org/nixos/manual/release-notes.html#sec-release-19.09)
  # state, "When upgrading from NixOS 19.03, please make sure that system.stateVersion is set to "19.03", or lower if the installation dates back to an earlier version of NixOS."
  system.stateVersion = "20.09";
  # PITFALL: read preceding comment.
}
