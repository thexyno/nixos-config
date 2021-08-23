{ inputs, config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.gui.gnome;
  laptop = config.ragon.hardware.laptop.enable;
  username = config.ragon.user.username;
in
{
  options.ragon.gui.gnome.enable = mkEnableOption "Enables ragons Gnome stuff";
  config = mkIf cfg.enable {
    services.tlp.enable = mkForce false; # gnome has it's own thing
    environment.systemPackages = with pkgs; [
      gnomeExtensions.gtile
      gnome.gnome-tweaks
      alacritty
    ];
    environment.variables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
    
    services.xserver.displayManager.defaultSession = mkForce "gnome";
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
    programs.dconf.enable = true;
    services.gnome.games.enable = true;
    services.gnome.core-developer-tools.enable = true;
  };
}
