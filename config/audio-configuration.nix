# SEE ALSO the portion of `./audio-configuration.nix` titled "Sound".

# This is based on (and minus my username, a strict subset of)
# these files from magnetophon's config:
  # https://github.com/magnetophon/nixosConfig/blob/master/music.nix
  # https://github.com/magnetophon/nixosConfig/blob/master/commonRT.nix
  # https://github.com/magnetophon/nixosConfig/blob/master/machines/mixos/default.nix

{pkgs, ...}:

with pkgs; {

  musnix = {
    enable = true;
    kernel.realtime = true;
    das_watchdog.enable = true; # kills RT processes that hang the system
    alsaSeq.enable = false;

    # Find this value with `lspci | grep -i audio` (per the musnix readme).
    # Some of the Musnix documentation for it:
    #   The PCI ID of the primary soundcard.
    #   Used to set the PCI latency time.
    #   If you have a USB sound card, this option is not useful.
    soundcardPciId = "00:1f.3";

    # Prioritizes audio somehow.
    rtirq = {
      # highList = "snd_hrtimer";
      resetAll = 1;
      prioLow = 0;
      enable = true;
      nameList = "rtc0 snd";
    };
  };

  # Desktop-launched apps inherit ("realtime priority"?) limits
  # from user@.service, not from PAM's limits.conf.
  # These settings give user services and desktop apps
  # permission to use RT scheduling and lock memory.
  # Apps must explicitly request RT to use it; normal apps are unaffected.
  systemd.user.settings.Manager = {
    DefaultLimitRTPRIO = 99;
    DefaultLimitMEMLOCK = "infinity";
  };
  systemd.services."user@".serviceConfig = {
    LimitRTPRIO = "infinity";
    LimitMEMLOCK = "infinity";
  };

  # Intel SOF audio shares the HDA bus with the GPU and won't
  # initialize unless a GPU driver is loaded. The musnix RT kernel
  # only has CONFIG_DRM_XE (not i915), and xe doesn't auto-probe
  # Raptor Lake GPU a7a0, so we force it. dsp_driver=3 selects
  # SOF over the legacy HDA path.
  boot.kernelParams = [
    "snd_intel_dspcfg.dsp_driver=3"  # select SOF audio driver
    "xe.force_probe=a7a0"            # xe GPU for Raptor Lake
  ];

  # snd_soc_avs competes with SOF for the same HDA PCI device.
  boot.blacklistedKernelModules = [ "snd_soc_avs" ];

  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=3
    softdep snd_sof_pci_intel_tgl pre: xe
    blacklist snd_soc_avs
  '';

  # xe must load before SOF probes, so it finds the GPU driver.
  # iwlwifi doesn't auto-load on the RT kernel.
  boot.kernelModules = [
    "xe"
    "iwlwifi"
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  # PipeWire's module-rt acquires RT scheduling via rtkit.
  # rtkit's default max is 20, which is too low for glitch-free
  # audio at 256/48000. 88 gives the data-loop thread enough
  # priority to preempt desktop work. 89 is rtkit's own priority,
  # which must be >= max-realtime-priority.
  security.rtkit.args = [
    "--max-realtime-priority=88"
    "--our-realtime-priority=89"
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;  # apps that use Pulse thereby use Pipewire
    jack.enable = true;   # apps that use Jack thereby use Pipewire
    wireplumber.enable = true; # session manager; tells PipeWire about ALSA devices
    extraConfig = {
      # The default JACK latency is 1024/48000.
      # This entire `extraConfig` was just to change that.
      # Maybe I could get rid of the rest of it.
      jack = {
        "10-clock-rate" = {
          "jack.properties" = {
            # 256 = 5.3ms latency at 48kHz. Increase if crackles occur.
            "node.latency" = "256/48000";
            "node.rate" = "1/48000";
          };
        };
      };
      pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [
              44100
              48000
            ];
            # 256 = 5.3ms latency at 48kHz. Increase if crackles occur.
            "default.clock.quantum" = 256;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 8192;
          };
        };

        #  # TODO: I hoped this would make a2jmidid default to creating 2 ports,
        #  # rather than 1. I don't think it does, but I'll have to reboot
        #  # before I know for sure.
        #  "11-virtual-devices" = {
        #    "context.objects" = [
        #      { factory = "adapter";
        #        args = { "audio.position" = "FL,FR";
        #                 "factory.name" = "support.null-audio-sink";
        #                 "media.class" = "Audio/Source/Virtual";
        #                 "node.description" = "Lumatone";
        #                 "node.name" = "lumatone";
        #               }; }
        #      { factory = "adapter";
        #        args = { "audio.position" = "FL,FR";
        #                 "factory.name" = "support.null-audio-sink";
        #                 "media.class" = "Audio/Source/Virtual";
        #                 "node.description" = "Zendrum";
        #                 "node.name" = "zendrum";
        #               }; } ]; }; }; };
      };
    };
  };

  # services.tlp.enable = false; # a power management daemon
  # services.jack.jackd.enable = true; # note: also mentioned in the
    # big commented-out section below about JACK, from the NixOS WIKI.

  # This lets the `jeff` user execute `systemctl`
  # without entering a password. It was in audio-configuration.nix.
  security.sudo.extraConfig = ''
    jeff  ALL=(ALL) NOPASSWD: ${pkgs.systemd}/bin/systemctl
    '';

  imports = [ /home/jeff/nix/musnix ];
  # PITFALL: This can stop working if my musnix repo is out of date.
  # That happened on 2021 04 02, causing a "cannot download rtirq-<number>"
  # error, making no mention of musnix.
}
