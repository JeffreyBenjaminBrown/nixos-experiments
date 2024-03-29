{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;

  imports =
    [ # Be sure to include the results of the hardware scan,
      # not just the files I wrote.
      ./hardware-configuration.nix
      ./packages.nix
    ];

  environment.variables = # customize Bash (and other stuff?)
    { EDITOR = "mg"; };

  nixpkgs.config.allowUnfree = true; # for Spotify, maybe Chrome
  # virtualisation.docker.enable = true;
  environment.homeBinInPath = true; # that is, ~/bin

  networking.hostName = "2007-compaq";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  # services.printing.enable = true; # Enable CUPS

  # Enable sound
  sound.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  services.xserver.windowManager.xmonad.enable = true;

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
  services.xserver.libinput.enable = true;

  # Set time zone.
  time.timeZone = "America/Bogota";

  # User accounts.
  # TODO : Don't forget to set a password with ‘passwd’
  # by logging in as root after installing.
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

      # configurationLimit = 15;
        # Deletes all but the newest 15 generations automatically.
        # Suggested here: https://serverfault.com/questions/997055/nixos-rebuild-switch-fails-with-no-space-left-on-device
    };
  };

  # PITFALL: Probably not to modify.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05";
  # PITFALL: read preceding comment.
}
