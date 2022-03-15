{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.laptop;
in
{
  options.ragon.hardware.laptop.enable = lib.mkEnableOption "Enables laptop stuff (tlp,...)";
  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "poversave";
      };
    };
    services.xserver.libinput = {
      enable = true;
    };
    hardware.acpilight.enable = true;
    services.thermald.enable = true;
    ragon.hardware.bluetooth.enable = true; # laptops normally have BT
  };
}
