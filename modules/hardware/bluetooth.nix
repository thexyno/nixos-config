{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.bluetooth;
in
{
  options.ragon.hardware.bluetooth.enable = lib.mkEnableOption "Enables bluetooth stuff (tlp,...)";
  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.pulseaudio = {
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
    ragon.gui.autostart = [
      ["${pkgs.blueberry}/bin/blueberry-tray"]
    ];

      
  };
}
