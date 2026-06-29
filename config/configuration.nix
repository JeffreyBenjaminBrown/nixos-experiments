{ pkgs, ... }:

{
  system.autoUpgrade = {
    enable = false;
    dates = "02:00";
    # allowReboot = true;
  };

  #  # I added this so I can read an iPhone; see
  #  # https://nixos.wiki/wiki/IOS
  #  services.usbmuxd.enable = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./audio-configuration.nix
      ./pipewire-upgrade.nix  # bump pipewire/wireplumber past the channel's
                              # 1.2.6 so the container's 1.6.3 clients (beep
                              # hook, synths) aren't stalled by a server too old
                              # to schedule their async nodes.
      ./packages.nix
      ./monome.nix
      # ./emacs.nix # This is imported from packages.nix, not here.
    ];

  programs.steam = {
    enable = true;

    # Open ports for ...
    remotePlay.openFirewall = true; # Steam Remote Play
    dedicatedServer.openFirewall = true; # Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;
      # Steam Local Network Game Transfers
  };

  environment = {
    # The `pathsToLink` and `LV2_PATH` code here is from polygon:
    # https://discourse.nixos.org/t/manually-installed-audio-plugins-found-but-nix-built-ones-not-found/57149/2
    pathsToLink = [
      "/lib/vst2" "/lib/vst3" "/lib/clap" "lib/lv2" ];
    variables = {
      # LV2_PATH = "/run/current-system/sw/lib/lv2";
      EDITOR = "mg"; };
    homeBinInPath = true; # that is, ~/bin
  };

  nixpkgs.config.allowUnfree = true; # for Spotify, ?Steam, ?Chrome
  virtualisation.docker = {
    enable = true;
    # Just run `docker exec -u 0` to get around this stuff.
    #rootless = {
    #  enable = true;
    #  setSocketVariable = true;
    #};
  };

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance"; # for audio
  services.power-profiles-daemon.enable = false; # overrides
    # cpuFreqGovernor with "balanced" (powersave); KDE enables it
    # by default

  # SOF and ALSA firmware for Intel HDA audio via SOF driver
  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  networking.hostName = "jbb-hp24-oled";
  networking.networkmanager.enable = true;

  services.printing.enable = true; # Enable CUPS

  services.xserver = { # X11. "Optional", per the wiki page on KDE: https://wiki.nixos.org/wiki/KDE
    enable = true;
    xkb = {
      layout = "us";
      options = "caps:escape";
      variant = "";
    };
  };

  # KDE
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

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

  services.libinput.enable = true; # touchpad support

  time.timeZone = "America/Los_Angeles";

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
    enableSSHSupport = true;

    # pinentryPackage = lib.mkForce pkgs.pinentry-gtk2;
    # I first put this here as a result of the discussion at
    # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/2
    # At that time the option was called `pinentryFlavor`
    # rather than `pinentryPackage`,
    # and it only needed a string like "gtk2"
    # rather than a `lib.mkForce` statement, which was suggested at
    # https://discourse.nixos.org/t/help-with-pinentrypackage/41393/7
    # I haven't been able to get it to work,
    # and I can't remember why I needed it once,
    # so I'll just comment it out for now.
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NixOS uses the LTS Linux kernel by default.
  # Musnix overrides the kernel to the RT one
  #   when kernel.realtime = true.
  # If musnix weren't doing that, this would use a more recent kernel:
  #   boot.kernelPackages = pkgs.linuxPackages_latest;
  #
  # PITFALL: To avoid surprise RT kernel rebuilds (which take a long
  # time), don't run `sudo nix-channel --update` unless you're
  # prepared for a rebuild. Changes to boot.kernelParams,
  # boot.extraModprobeConfig, boot.blacklistedKernelModules, and
  # boot.kernelModules do NOT trigger kernel recompilation — only
  # channel updates (new kernel source) or boot.kernelPatches changes do.
  #
  # To pin nixpkgs and prevent ANY channel drift, uncomment and
  # adjust the following (you'll need to compute the sha256 once with
  # `nix-prefetch-url --unpack <url>`):
  #
  #   nixpkgs.source = builtins.fetchTarball {
  #     url = "https://github.com/NixOS/nixpkgs/archive/c06b4ae3d659.tar.gz";
  #     sha256 = ""; # fill in via nix-prefetch-url --unpack <url>
  #   };

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
