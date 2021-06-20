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
      Unit.Description = "Mpris proxy";
      Unit.After = [ "network.target" "sound.target" ];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = [ "default.target" ];
    };
    hardware.pulseaudio = {
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
    ragon.gui.autostart = [
      "${pkgs.blueberry}/bin/blueberry-tray"
    ];

      
  };
}
