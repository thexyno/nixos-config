{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.gui.sway;
in
{
  options.ragon.gui.sway.enable = lib.mkEnableOption "Enables ragons sway stuff";
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      # gtkUsePortal = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            chooser_type = "dmenu";
            chooser_cmd = "''${pkgs.wofi}/bin/wofi -d";
          };
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            let
              gtkgreetcss = pkgs.writeText "gtkgreetcss" ''
                window {
                  background-image: url("file:///persistent/home/ragon/Backgrounds/asdf.jpg");
                  background-size: cover;
                  background-position: center;
                  }
              '';
              swaycfg = pkgs.writeText "swaycfg" ''
                exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s ${gtkgreetcss} -c sway; swaymsg exit"
                bindsym Mod4+shift+e exec swaynag \
                  -t warning \
                  -m 'What do you want to do?' \
                  -b 'Poweroff' 'systemctl poweroff' \
                  -b 'Reboot' 'systemctl reboot'
                include /etc/sway/config.d/*
              '';
            in
            "sh -c 'XDG_CURRENT_DESKTOP=sway sway --config ${swaycfg}'";
        };
      };
    };
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
      pkgs.swappy
      pkgs.grim
      pkgs.slurp
      pkgs.jq
      pkgs.wl-clipboard
    ];

  };
}
