{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;

  # Load sources
  sources = import ../nix/sources.nix;
in
{
  options.ragon.home-manager.enable = lib.mkEnableOption "Enables my home-manager config";

  # Import the home-manager module
  imports = [ "${sources.home-manager}/nixos" ];

  config = lib.mkIf cfg.enable {
    # Make sure to start the home-manager activation before I log it.
    systemd.services."home-manager-${config.my.user.username}" = {
      before = [ "display-manager.service" ];
      wantedBy = [ "multi-user.target" ];
    };

    home-manager.users.${config.ragon.user.username} = { pkgs, ... }:
      let
      in
      {
        # Import a persistance module for home-manager.
        imports = [ "${sources.impermanence}/home-manager.nix" ];

        programs.home-manager.enable = true;

        home.persistence.${config.ragon.user.persistent.homeDir} = {
          files = [ ] ++ config.ragon.user.persistent.extraFiles;
          directories = [ ] ++ config.ragon.user.persistent.extraDirectories;
        };

        home.file = {
          # Home nix config.
          ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";

          # Nano config
          ".nanorc".text = "set constantshow # Show linenumbers -c as default";

        } // lib.optionalAttrs gui.enable {

        };

        kitty = {
          enable = gui.enable;
          font = {
            package = pkgs.jetbrains-mono;
            name = "JetBrains Mono Medium";
          };
          settings = {
            "enable_audio_bell" = "false";
            "allow_remote_control" = "yes";
            "sync_to_monitor" = "yes";
            "background" = "#282828";
            "foreground" = "#ebdbb2";
            "background_opacity" = "1.0";
            "font_size" = "12";
          };
          keybindings = {
            "ctrl+minus" = "change_font_size all -2.0";
            "ctrl+plus" = "change_font_size all +2.0";
          };

        };
        programs.git = {
          enable = true;

          # Default configs
          extraConfig = {
            commit.gpgSign = true;

            user.name = "Philipp Hochkamp";
            user.email = "me@phochkamp.de";
            user.signingKey = "26F03E1F60F5731B0CC5BDE1C4F2B751AA7341B3";

            # Set default "git pull" behaviour so it doesn't try to default to
            # either "git fetch; git merge" (default) or "git fetch; git rebase".
            pull.ff = "only";
          };
        };

        xdg.mimeApps = {
          enable = gui.enable;
          defaultApplications = {
            "text/html" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          };

          associations.added = {
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          };
        };

        # Htop configurations
        programs.htop = {
          enable = true;
          hideUserlandThreads = true;
          highlightBaseName = true;
          shadowOtherUsers = true;
          showProgramPath = false;
          treeView = true;
          meters = {
            left = [  "LeftCPUs"  "Memory" "Swap"        "ZFSARC" "ZFSCARC" ];
            right = [ "RightCPUs" "Tasks"  "LoadAverage" "Uptime" "Battery" ];
          };
        };

        # GTK theme configs
        gtk.enable = gui.enable;
        gtk.gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        # Set up qt theme as well
        qt = {
          enable = gui.enable;
          platformTheme = "gtk";
        };

        # Enable the dunst notification deamon
        services.dunst.enable = gui.enable;
        services.dunst.settings = {
          global = {
            # font = "";

            # Allow a small subset of html markup
            markup = "yes";
            plain_text = "no";

            # The format of the message
            format = "<b>%s</b>\\n%b";

            # Alignment of message text
            alignment = "center";

            # Split notifications into multiple lines
            word_wrap = "yes";

            # Ignore newlines '\n' in notifications.
            ignore_newline = "no";

            # Hide duplicate's count and stack them
            stack_duplicates = "yes";
            hide_duplicates_count = "yes";

            # The geometry of the window
            geometry = "420x50-15+49";

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
            dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst -theme glue_pro_blue";

            # Browser for opening urls in context menu.
            browser = "/run/current-system/sw/bin/firefox -new-tab";

            # Align icons left/right/off
            icon_position = "left";
            max_icon_size = 80;

            # Define frame size and color
            frame_width = 3;
            frame_color = "#8EC07C";
          };

          shortcuts = {
            close = "ctrl+space";
            close_all = "ctrl+shift+space";
          };

          urgency_low = {
            frame_color = "#3B7C87";
            foreground = "#3B7C87";
            background = "#191311";
            timeout = 4;
          };
          urgency_normal = {
            frame_color = "#5B8234";
            foreground = "#5B8234";
            background = "#191311";
            timeout = 6;
          };

          urgency_critical = {
            frame_color = "#B7472A";
            foreground = "#B7472A";
            background = "#191311";
            timeout = 8;
          };
        };

        services.picom.enable = gui.enable;
        services.picom.vSync = true;

        home.stateVersion = "20.09";
      };
  };
}
