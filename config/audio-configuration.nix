# This is based on (and minus my username, a strict subset of)
# these files from magnetophon's config:
  # https://github.com/magnetophon/nixosConfig/blob/master/music.nix
  # https://github.com/magnetophon/nixosConfig/blob/master/commonRT.nix
  # https://github.com/magnetophon/nixosConfig/blob/master/machines/mixos/default.nix
#
# Some parts of this file is magic to me. Those are marked "magic".

{pkgs, ...}:

with pkgs; {

  # services.tlp.enable = false; # a power management daemon
  # services.jack.jackd.enable = true; # note: also mentioned in the
    # big commented-out section below about JACK, from the NixOS WIKI.

  # magic to me
  security.sudo.extraConfig = ''
    jeff  ALL=(ALL) NOPASSWD: ${pkgs.systemd}/bin/systemctl
    '';

  # TODO ? Re-enable.
  imports = [ /home/jeff/nix/musnix ];

  # PITFALL: This can stop working if my musnix repo is out of date.
  # That happened on 2021 04 02, causing a "cannot download rtirq-<number>"
  # error, making no mention of musnix.

  musnix = {
    enable = true;
    alsaSeq.enable = false;

    # Find this value with `lspci | grep -i audio` (per the musnix readme).
    # PITFALL: This is the id of the built-in soundcard.
    #   When I start using the external one, change it.
    soundcardPciId = "00:1f.3";

    # At least one of these doesn't seem to want to build.
    # I haven't tried either without the other.
    # kernel.realtime = true;
    # kernel.optimize = true;

    # das_watchdog.enable = true;
      # I don't think this does anything without the realtime kernel.

    # magic to me
    rtirq = {
      # highList = "snd_hrtimer";
      resetAll = 1;
      prioLow = 0;
      enable = true;
      nameList = "rtc0 snd";
    };
  };
}
