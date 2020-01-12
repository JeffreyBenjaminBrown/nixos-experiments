# This is based on (and minus my username, a strict subset of)
# magnetophon's commonRT.nix and music.nix files:
  # https://github.com/magnetophon/nixosConfig/blob/master/commonRT.nix

# PITFALL: magnetophon notes that one should:
  # set soundcardPciId
    # which I have done, I think, vvia one of the musnix options.
  # set rtirq.nameList
    # but I haven't, because I haven't yet rebuilt the kernel for realtime.
    # (see the musnix readme, which discusses both kernel and rtirq).

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
    # TODO. These require rebuilding the kernel.
      # musnix.kernel.optimize = true;
      # musnix.kernel.realtime = true;
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
