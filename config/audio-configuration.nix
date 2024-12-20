# SEE ALSO the portion of `./audio-configuration.nix` titled "Sound".

# This is based on (and minus my username, a strict subset of)
# these files from magnetophon's config:
  # https://github.com/magnetophon/nixosConfig/blob/master/music.nix
  # https://github.com/magnetophon/nixosConfig/blob/master/commonRT.nix
  # https://github.com/magnetophon/nixosConfig/blob/master/machines/mixos/default.nix

{pkgs, ...}:

with pkgs; {

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
    jack.enable = true;
    extraConfig = {
      # The default JACK latency is 1024/48000.
      # This entire `extraConfig` was just to change that.
      # Maybe I could get rid of the rest of it.
      jack = {
        "10-clock-rate" = {
          "jack.properties" = {
            "node.latency" = "128/48000";
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
            "default.clock.quantum" = 128;
            "default.clock.min-quantum" = 16;
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

  musnix = {
    enable = true;
    alsaSeq.enable = false;

    # Find this value with `lspci | grep -i audio` (per the musnix readme).
    # Some of the Musnix documentation for it:
    #   The PCI ID of the primary soundcard.
    #   Used to set the PCI latency time.
    #   If you have a USB sound card, this option is not useful.
    soundcardPciId = "00:1f.3";

    # At least one of these doesn't seem to want to build.
    # I haven't tried either without the other.
    # kernel.realtime = true;
    # kernel.optimize = true;

    # das_watchdog.enable = true;
      # I don't think this does anything without the above realtime kernel.

    # Prioritizes audio somehow.
    rtirq = {
      # highList = "snd_hrtimer";
      resetAll = 1;
      prioLow = 0;
      enable = true;
      nameList = "rtc0 snd";
    };
  };
}
