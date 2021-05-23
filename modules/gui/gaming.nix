{ config, lib, pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
  cfg = config.ragon.gui.gaming;
in
{
  options.ragon.gui.gaming.enable = lib.mkEnableOption "Enables Ragons Gaming stuff";
  config = lib.mkIf cfg.enable {
    hardware.opengl.driSupport32Bit = true;
    programs.steam.enable = true;
    environment.systemPackages = with pkgs; [
      lutris
      wineWowPackages.stable
    ];

  };
}
