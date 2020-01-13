# This is based on (and minus my username, a strict subset of)
# magnetophon's commonRT.nix and music.nix files:
  # https://github.com/magnetophon/nixosConfig/blob/master/commonRT.nix

# PITFALL: magnetophon notes that one should set
  # soundcardPciId and rtirq.nameList
  # I hope I have in fact done that.
  # I'm assuming he means the so-named musnix options.
  # PITFALL: In the case of rtirq.nameList, I just copied what he uses;
  # that could be wrong.

{config, lib, pkgs, options, modulesPath}:

with pkgs; {
  imports = [ /home/jeff/nix/musnix ];

  musnix = {
    enable = true;
    alsaSeq.enable = true;
    soundcardPciId = "00:1f.3";
      # PITFALL: This is the id of the built-in soundcard.
      # When I start using the external one, change it.
      # Find it with `lspci | grep -i audio` (per the musnix readme).
    rtirq.nameList = "rtc0 snd";
      # PITFALL: copied with no idea what I'm doing. from
      # https://github.com/magnetophon/nixosConfig/blob/master/machines/mixos/default.nix
    kernel.optimize = true;
    kernel.realtime = true;
    kernel.packages = pkgs.linuxPackages_4_19_rt;
      # PITFALL: magnetophon specifies this. I don't know why.
      # When I tried the default (5_0_rt), NixOS couldn't download
      # http://www.rncbc.org/archive/rtirq-20190129.tar.gz,
      # so now I'm trying this.
    rtirq.enable = true;
    das_watchdog.enable = true;
  };

  services.tlp.enable = false; # a power management daemon
  services.jack.jackd.enable = true; # note: also mentioned in the
    # big commented-out section below about JACK, from the NixOS WIKI.

  nixpkgs.config.packageOverrides = pkgs: rec {
    qjackctl = pkgs.stdenv.lib.overrideDerivation pkgs.qjackctl (
      oldAttrs: { configureFlags =
                    "--enable-jack-version --disable-xunique";
                  # fix bug for remote running
                }); };

  security.sudo.extraConfig = ''
  jeff  ALL=(ALL) NOPASSWD: ${pkgs.systemd}/bin/systemctl
  '';

  environment.systemPackages = [
    a2jmidid
    carla
    jack2Full
    jack_capture
    qjackctl
    cadence
    flac
    jack_oscrolloscope
    jackmeter
    jalv
    lilv
    liblo
    ladspaH
    supercollider
    supercollider_scel
    vmpk # virtual MIDI keyboard

    graphviz # why is this here?
      # https://github.com/magnetophon/nixosConfig/blob/master/music.nix
    # leiningen # for Clojure
    jaaa # signal analyzer
    japa # psychoacoustic signal analyzer
    sooperlooper
    squishyball # for A/B testing. Not clearly audio software.
    sox
    shntool # view and modify WAVE files
    x42-plugins # level meters
    ladspa-sdk
    QmidiNet # "a midi network gateway"
  ];
}
