# Monome (grids, arcs) support: libmonome + serialosc.
#
# Provides:
# - `libmonome` (C library) and `serialosc` (OSC bridge daemon) as
#   system packages. At build time they are read from
#   `./custom-packages/{libmonome,serialosc}` RELATIVE TO THIS FILE'S
#   LOCATION, which is /etc/nixos after `bash/copy.sh` stages them.
#   (In the source repo the same trees live at ../custom-packages/,
#   a sibling of config/, but copy.sh flattens them.)
#   Added via a nixpkgs overlay, so `pkgs.libmonome` / `pkgs.serialosc`
#   are available anywhere in the config.
# - A systemd user service `serialoscd.service` that starts
#   serialoscd on login and restarts it on failure. Plugged-in
#   monomes become available on OSC automatically; no imperative
#   install step required.
#
# Prerequisites (already satisfied in configuration.nix):
# - User must be in the `dialout` group. ftdi_sio assigns FTDI
#   USB-serial devices (which monomes are) to dialout:660. Jeff's
#   user already has `dialout` in `extraGroups`.
#
# When upstream nixpkgs accepts libmonome/serialosc, drop the overlay
# and keep only the `systemd.user.services` block.

{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      libmonome = super.callPackage ./custom-packages/libmonome { };
      serialosc = super.callPackage ./custom-packages/serialosc {
        libmonome = self.libmonome;
      };
    })
  ];

  environment.systemPackages = [ pkgs.libmonome pkgs.serialosc ];

  systemd.user.services.serialoscd = {
    description = "serialosc OSC bridge daemon for monome devices";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.serialosc}/bin/serialoscd";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };
}
