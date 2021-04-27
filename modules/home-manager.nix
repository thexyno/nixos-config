{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;

in
{
  options.ragon.home-manager.enable = lib.mkEnableOption "Enables my home-manager config";

  # Import the home-manager module
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = lib.mkIf cfg.enable {
    # Make sure to start the home-manager activation before I log it.
    systemd.services."home-manager-${config.ragon.user.username}" = {
      before = [ "display-manager.service" ];
      wantedBy = [ "multi-user.target" ];
    };
    environment.systemPackages = with pkgs;[
      dunst # dunstify
    ];
    programs.fuse.userAllowOther = true; # for persistence user dirs to work

    age.secrets.nextshot.file = ../secrets/nextshot.age;
    age.secrets.nextshot.owner = config.ragon.user.username;

    home-manager.users.${config.ragon.user.username} = { pkgs, ... }:
      let
      in
      {
        # Import a persistance module for home-manager.
        ## TODO this can be done less ugly
        imports = [ "${inputs.impermanence}/home-manager.nix" ];

        programs.home-manager.enable = true;

        home.persistence.${config.ragon.user.persistent.homeDir} = {
          files = [ ] ++ config.ragon.user.persistent.extraFiles;
          directories = [ ] ++ config.ragon.user.persistent.extraDirectories;
          allowOther = true;
        };

        home.file = {
          # Home nix config.
          ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
          ".local/share/pandoc/templates/default.latex".source = "${inputs.pandoc-latex-template}/eisvogel.tex";

          # Nano config
          ".nanorc".text = "set constantshow # Show linenumbers -c as default";
          # empty zshrc to stop zsh-newuser-install from running
          ".zshrc".text = "";

          "bin/changeVolume".source = ./bins/changeVolume;
          "bin/devsaurgit".source = ./bins/devsaurgit;
          "bin/getProgressString".source = ./bins/getProgressString;
          "bin/swapDevices".source = ./bins/swapDevices;
          "bin/toggleSpeakers".source = ./bins/toggleSpeakers;
          "bin/nosrebuild".source = ./bins/nosrebuild;
        } // lib.optionalAttrs isGui {
          "bin/changeBacklight".source = ./bins/changeBacklight;
          "bin/nextshot".source = "${inputs.nextshot}/nextshot.sh";
          ".config/nextshot/nextshot.conf".source = age.secrets.nextshot.path;
        };

        programs = {
          bat = {
            enable = true;
            config.theme = "gruvbox-dark";
          };
          fzf = {
            enable = true;
            enableZshIntegration = true;
            defaultOptions = [
              "--height 40%"
              "--layout=reverse"
              "--border"
              "--inline-info"
            ];
          };
          kitty = {
            enable = isGui;
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
          git = {
            enable = true;
            lfs.enable = true;

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
          # Htop configurations
          htop = {
            enable = true;
            hideUserlandThreads = true;
            highlightBaseName = true;
            shadowOtherUsers = true;
            showProgramPath = false;
            treeView = true;
            meters = {
              left = [ "LeftCPUs" "Memory" "Swap" "ZFSARC" "ZFSCARC" ];
              right = [ "RightCPUs" "Tasks" "LoadAverage" "Uptime" "Battery" ];
            };
          };


          rofi = {
            enable = true;
            font = "JetBrains Mono Medium 10";
            terminal = "${pkgs.kitty}/bin/kitty";
            extraConfig = {
              modi = "drun,run,ssh,combi";
              theme = "gruvbox-dark-soft";
              combi-modi = "drun,run,ssh";
            };

          };

        };

        xdg.dataFile = {
          "applications/Firefox (Work).desktop".text = ''
            [Desktop Entry]
            Categories=Network;WebBrowser;
            Comment=
            Exec=firefox -P Work %U
            GenericName=Web Browser (Work)
            Icon=firefox
            Name=Firefox (Work)
            Terminal=false
            Type=Application
          '';

        };

        xdg.mimeApps = {
          enable = isGui;
          defaultApplications = {
            "text/html" = [ "firefox.desktop" ];
            "application/pdf" = [ "org.pwmt.zathura.desktop" ]; #
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


        # GTK theme configs
        gtk.enable = isGui;
        gtk.gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        # Set up qt theme as well
        qt = {
          enable = isGui;
          platformTheme = "gtk";
        };
        services.random-background = {
          enable = isGui;
          enableXinerama = true;
          imageDirectory = "%h/Backgrounds";
          interval = "1h";
        };

        # Enable the dunst notification deamon
        services.dunst.enable = isGui;
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

        services.picom.enable = isGui;
        services.picom.vSync = true;

        home.stateVersion = "20.09";
      };
  };
}
