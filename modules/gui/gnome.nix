{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.gui.gnome;
  laptop = config.ragon.hardware.laptop.enable;
  username = config.ragon.user.username;
in
{
  options.ragon.gui.gnome.enable = lib.mkEnableOption "Enables ragons Gnome stuff";
  config = lib.mkIf cfg.enable {
    services.tlp.enable = lib.mkForce false; # gnome has it's own thing
    environment.variables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
    
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
    programs.dconf.enable = true;
    services.gnome3.evolution-data-server.enable = true;
    # optional to use google/nextcloud calendar
    services.gnome3.gnome-online-accounts.enable = true;
    # optional to use google/nextcloud calendar
    services.gnome3.gnome-keyring.enable = true;
  };
}
