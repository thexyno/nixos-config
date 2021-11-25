{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isSway = config.ragon.gui.sway.enable;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
      {
        # GTK theme configs
        gtk.enable = isGui;
        gtk.gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        services.random-background = {
          enable = isGui && !isSway;
          enableXinerama = true;
          imageDirectory = "%h/Backgrounds";
          interval = "1h";
        };

        programs.rofi = {
          enable = isGui && !isSway;
          terminal = "${pkgs.kitty}/bin/kitty";
          extraConfig = {
            modi = "drun,run,ssh,combi";
            theme = "gruvbox-dark-soft";
            combi-modi = "drun,run,ssh";
          };
        };

        # Enable the dunst notification deamon
        services.dunst.enable = isGui && !isSway;
        services.dunst.settings = {
          global = {
            font = "JetBrainsMono Nerd Font 12";

            # Allow a small subset of html markup
            markup = "full";
            plain_text = "no";

            # The format of the message
            format = "<b>%s</b>\\n%b";

            # Alignment of message text
            alignment = "left";

            # Split notifications into multiple lines
            word_wrap = "yes";

            # Ignore newlines '\n' in notifications.
            ignore_newline = "no";

            # Hide duplicate's count and stack them
            stack_duplicates = "yes";
            hide_duplicates_count = "yes";

            # The geometry of the window
            geometry = "400x7-30+20";
            follow = "mouse";

            # Shrink window if it's smaller than the width
            shrink = "no";

            # Don't remove messages, if the user is idle
            idle_threshold = 0;

            # Which monitor should the notifications be displayed on.
            monitor = 0;

            # The height of a single line. If the notification is one line it will be
            # filled out to be three lines.
            line_height = 3;

            # Draw a line of "separatpr_height" pixel height between two notifications
            separator_height = 2;

            # Padding between text and separator
            padding = 6;
            horizontal_padding = 6;

            # Define a color for the separator
            separator_color = "frame";

            # dmenu path
            dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";

            # Browser for opening urls in context menu.
            browser = "/run/current-system/sw/bin/firefox -new-tab";

            # Align icons left/right/off
            icon_position = "left";
            max_icon_size = 80;

            # Define frame size and color
            frame_width = 3;
            frame_color = "#A89984";
          };

          shortcuts = {
            close = "ctrl+space";
            close_all = "ctrl+shift+space";
            context = "ctrl+period";
          };

          urgency_low = {
            background = "#282828";
            foreground = "#EBDBB2";
            timeout = 10;
          };
          urgency_normal = {
            background = "#262626";
            foreground = "#EBDBB2";
            timeout = 10;
          };

          urgency_critical = {
            background = "#242424";
            foreground = "#EBDBB2";
            timeout = 10;
          };
        };

        services.picom.enable = isGui && !isSway;
        services.picom.vSync = true;
        services.mpris-proxy.enable = true;

        services.screen-locker = {
          enable = config.ragon.hardware.laptop.enable && !isSway;
          lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
        };

      };
  };
}
