{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.nvidia;
in
{
  options.ragon.hardware.laptop.enable = lib.mkEnableOption "Enables laptop stuff (tlp,...)";
  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
      };
    };
    services.xserver.libinput = {
      enable = true;
    };
    hardware.acpilight.enable = true;
    config.ragon.gui.laptop = true;

  };
}
