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
      xdg-desktop-portal-wlr
      obs-studio-plugins.wlrobs
      swaybg
    ];
    environment.variables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XKB_DEFAULT_LAYOUT = "${config.services.xserver.layout}";
      XKB_DEFAULT_OPTIONS = "${config.services.xserver.xkbOptions}";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_CURRENT_DESKTOP = "unity";
    };
    # Config File is in home-manager/river.nix
    
  };
}
