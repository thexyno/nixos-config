{ inputs, config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.gui.river;
in
{
  options.ragon.gui.river.enable = mkEnableOption "Enables ragons River stuff";
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      river
      wofi
      alacritty
    ];
    environment.variables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XKB_DEFAULT_LAYOUT = "${config.services.xserver.layout}";
      XKB_DEFAULT_OPTIONS = "${config.services.xserver.xkbOptions}";
    };
    # Config File is importe in home-manager/river.nix
    
  };
}
