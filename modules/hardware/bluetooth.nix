{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.bluetooth;
in
{
  options.ragon.hardware.bluetooth.enable = lib.mkEnableOption "Enables bluetooth stuff (tlp,...)";
  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = [ "network.target" "sound.target" ];
      script = "${pkgs.bluez}/bin/mpris-proxy";
      wantedBy = [ "default.target" ];
    };
    hardware.pulseaudio = {
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
    ragon.gui.autostart = [
      ["${pkgs.blueberry}/bin/blueberry-tray"]
    ];

      
  };
}
