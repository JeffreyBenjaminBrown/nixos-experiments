{ pkgs, ... }:

{
  system.autoUpgrade = {
    enable = false;
    dates = "02:00";
    # allowReboot = true;
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./audio-configuration.nix
      ./packages.nix
      # ./emacs.nix # This is imported from packages.nix, not here.
    ];

  environment.variables = # customize Bash (and other stuff?)
    { EDITOR = "mg"; };

  nixpkgs.config.allowUnfree = true; # for Spotify, maybe Chrome
  virtualisation.docker.enable = true;
  environment.homeBinInPath = true; # that is, ~/bin

  networking.hostName = "jbb-hp24-oled";
  networking.networkmanager.enable = true;

  services.printing.enable = true; # Enable CUPS

  # ---- Sound ----
  # These are *almost* the default NixOS 23.11 installer options.
  # The exception is services.pipewire.pulse.enable,
  # which I have made "false".
  # So far, nothing seems to mind -- not even Chrome.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
    jack.enable = true;
  };

  services.xserver = { # X11
    enable = true;
    layout = "us";
    xkbOptions = "caps:escape";
    xkbVariant = "";
  };

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Select internationalisation properties.
  i18n = {
    # PITFALL: I might someday want some of these to instead be
    # Colombian Spanish: es_CO.UTF-8
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # These are copied near-verbatim from my work system
      # (KUbuntu 18.04), except with more quotation marks
      # (it used them for English but not Spanish),
      # and space around the equals signs.
      # Most of them are Colombian Spanish; exceptions are noted.
      LANG              = "en_US.UTF-8";
      LANGUAGE          = "en_US.UTF-8";
        # The Ubuntu system shows "LANGUAGE="
        # when I evaluate `locale`.
      LC_CTYPE          = "en_US.UTF-8";
      LC_NUMERIC        = "en_US.UTF-8";
      LC_TIME           = "en_US.UTF-8";
      LC_COLLATE        = "en_US.UTF-8";
      LC_MONETARY       = "en_US.UTF-8";
      LC_MESSAGES       = "en_US.UTF-8";
      LC_PAPER          = "en_US.UTF-8";
      LC_NAME           = "en_US.UTF-8";
      LC_ADDRESS        = "en_US.UTF-8";
      LC_TELEPHONE      = "en_US.UTF-8";
      LC_MEASUREMENT    = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_ALL            = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver.libinput.enable = true; # touchpad support

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

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2"; # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/2
    enableSSHSupport = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NixOS uses the LTS Linux kernel by default.
  # This uses a later one.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # PITFALL: Probably not to modify.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. `man configuration.nix`
  # or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
  # PITFALL: Read preceding comment.
}
