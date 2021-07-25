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

    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
      {
        # Import a persistance module for home-manager.
        ## TODO this can be done less ugly
        imports = [ "${inputs.impermanence}/home-manager.nix" ];

        programs.home-manager.enable = true;

        home.persistence.${config.ragon.user.persistent.homeDir} = {
          files = [ ] ++ config.ragon.user.persistent.extraFiles;
          directories = [
            ".ssh"
            ".gnupg"
            "Downloads"
            "Backgrounds"
            "proj"
            "git"
          ] ++ config.ragon.user.persistent.extraDirectories;
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

          "bin/changeVolume".source = ../bins/changeVolume;
          "bin/devsaurgit".source = ../bins/devsaurgit;
          "bin/getProgressString".source = ../bins/getProgressString;
          "bin/swapDevices".source = ../bins/swapDevices;
          "bin/toggleSpeakers".source = ../bins/toggleSpeakers;
          "bin/nosrebuild".source = ../bins/nosrebuild;
        } // lib.optionalAttrs isGui {
          "bin/changeBacklight".source = ../bins/changeBacklight;
          "bin/nextshot".source = "${inputs.nextshot}/nextshot.sh";
        };
        #config.age.secrets.nextshot.path = "/home/${config.ragon.user.username}/.config/nextshot/nextshot.conf";

        programs = {

          autorandr.enable = true;
          autorandr.profiles = {
            "tv" = {
              fingerprint = {
                HDMI-1 = "00ffffffffffff004dd901ee010101010114010380a05a780a0dc9a05747982712484c21080081800101010101010101010101010101023a801871382d40582c450040846300001e011d007251d01e206e28550040846300001e000000fc00534f4e592054560a2020202020000000fd00303e0e460f000a20202020202001be02032cf0501f101405130412111615030207060120260907071507508301000068030c001000b82d0fe2007b023a80d072382d40102c458040846300001e011d00bc52d01e20b828554040846300001e011d8018711c1620582c250040846300009e011d80d0721c1620102c258040846300009e00000000000000000000000e";
                eDP-1 = "00ffffffffffff000daec91400000000081a0104951f11780228659759548e271e505400000001010101010101010101010101010101b43b804a71383440503c680035ad10000018000000fe004e3134304843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3134304843412d4541420a20003e";
              };
              config = {
                VGA-1.enable = false;
                DP-1.enable = false;
                DP-2.enable = false;
                HDMI-2.enable = false;
                eDP-1 = {
                  enable = true;
                  crtc = 1;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.01";
                };
                HDMI-1 = {
                  enable = true;
                  crtc = 1;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.00";
                };

              };


            };
            "work" = {
              fingerprint = {
                DP-2-2 = "00ffffffffffff0005e30124b24407001d1e010380341d782a9b15a655519d260d5054bfef00d1c0b30095008180814081c001010101023a801871382d40582c450009252100001e000000ff00474d584c374841343736333338000000fc0032344231570a20202020202020000000fd00324c1e5311000a202020202020011802031ef14b101f051404130312021101230907078301000065030c0010008c0ad08a20e02d10103e9600092521000018011d007251d01e206e28550009252100001e8c0ad08a20e02d10103e96000925210000188c0ad090204031200c40550009252100001800000000000000000000000000000000000000000000000000f1";
                DP-2-3 = "00ffffffffffff0005e30124a96107001f1e010368341d782a9b15a655519d260d5054bfef00d1c0b30095008180814081c001010101023a801871382d40582c450009252100001e000000ff00474d584c384841343833373533000000fc0032344231570a20202020202020000000fd00324c1e5311000a202020202020001b";
                eDP-1 = "00ffffffffffff000daec91400000000081a0104951f11780228659759548e271e505400000001010101010101010101010101010101b43b804a71383440503c680035ad10000018000000fe004e3134304843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3134304843412d4541420a20003e";
              };
              config = {
                VGA-1.enable = false;
                DP-1.enable = false;
                HDMI-1.enable = false;
                DP-2.enable = false;
                HDMI-2.enable = false;
                DP-2-1.enable = false;
                DP-2-3 = {
                  enable = true;
                  crtc = 2;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.00";
                };
                DP-2-2 = {
                  enable = true;
                  crtc = 1;
                  mode = "1920x1080";
                  position = "1920x0";
                  rate = "60.00";
                };
                eDP-1 = {
                  enable = true;
                  crtc = 0;
                  mode = "1920x1080";
                  position = "3840x0";
                  rate = "60.01";
                };
              };
            };
          };

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
          # \ragon
          # we live in a suckless household
          #kitty = {
          #  enable = isGui;
          #  font = {
          #    package = pkgs.jetbrains-mono;
          #    name = "JetBrains Mono Medium";
          #  };
          #  settings = {
          #    "enable_audio_bell" = "false";
          #    "allow_remote_control" = "yes";
          #    "sync_to_monitor" = "yes";
          #    "background" = "#282828";
          #    "foreground" = "#ebdbb2";
          #    "background_opacity" = "1.0";
          #    "font_size" = "12";
          #  };
          #  keybindings = {
          #    "ctrl+minus" = "change_font_size all -2.0";
          #    "ctrl+plus" = "change_font_size all +2.0";
          #  };

          #};
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
            settings = {
              hide_userland_threads = true;
              highlight_base_name = true;
              shadow_other_users = true;
              show_program_path = false;
              tree_view = false;
              left_meters = [ "LeftCPUs" "Memory" "Swap" "ZFSARC" ];
              right_meters = [ "RightCPUs" "Tasks" "LoadAverage" "Uptime" "Battery" ];
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
        services.mpris-proxy.enable = true;

        home.stateVersion = "21.05";
      };
  };
}
