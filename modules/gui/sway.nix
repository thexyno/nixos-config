{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.gui.sway;
in
{
  options.ragon.gui.sway.enable = lib.mkEnableOption "Enables ragons sway stuff";
  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures = {
        gtk = true;
      };
      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';

    };
    environment.systemPackages = [
      pkgs.playerctl
      pkgs.libnotify
      pkgs.qt5.qtwayland
      pkgs.ponymix
    ];

  };
}
