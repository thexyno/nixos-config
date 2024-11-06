{ lib, pkgs, config, inputs, ... }: {
  home.packages = with pkgs; [
    helvum
    brightnessctl
    dconf
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };
  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 20;
        modules-left = [ "river/tags" "river/mode" "river/layout" ];
        modules-center = [ "river/window" ];
        modules-right = [ "wireplumber" "upower" "backlight" "cpu" "temperature" "memory" "disk" "network" "clock" ];
        wireplumber = {
          "format" = "{volume}% {icon}";
          "format-muted" = "";
          "on-click" = "helvum";
          "format-icons" = [ "" "" "" ];
        };
        "backlight" = {
          "device" = "amdgpu_bl1";
          "format" = "{percent}% {icon}";
          "format-icons" = [ "" "" ];
        };
        "cpu" = {
          "interval" = 10;
          "format" = "{}% ";
          "max-length" = 10;
        };
        "temperature" = {
          "format" = "{temperatureC}°C ";
        };
        memory = {
          interval = 30;
          format = "{used:0.0f}/{total:0.0f} GB ";
        };
        clock = {
          interval = 1;
          format = "{:%Y-%m-%dT%H:%M:%S%z}";
        };
        disk = {
          format = "{specific_used:0.0f}/{specific_total:0.0f} GB 󰋊";
          unit = "GB";
          path = "/persistent";
        };
        "network" = {
          "format" = "{ifname}";
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} 󰊗";
          "format-disconnected" = "";
          "tooltip-format" = "{ifname} via {gwaddr} 󰊗";
          "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
          "tooltip-format-ethernet" = "{ifname} ";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = 50;
        };
      };
    };
  };
  wayland.windowManager.river = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    settings = {
      map = {
        normal = {
          "Super Q" = "close";
          "Super J" = "focus-view next";
          "Super K" = "focus-view previous";
          "Super Up" = "focus-view next";
          "Super Down" = "focus-view previous";
          "Super+Shift J" = "swap next";
          "Super+Shift K" = "swap previous";
          "Super+Shift Up" = "swap next";
          "Super+Shift Down" = "swap previous";
          "Super Period" = "focus-output right";
          "Super Comma" = "focus-output left";
          "Super+Control Period" = "send-to-output right";
          "Super+Control Comma" = "send-to-output left";
          "Super Return" = "zoom";
          "Super H" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
          "Super L" = ''send-layout-cmd rivertile "main-ratio +0.05"'';
          "Super Left" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
          "Super Right" = ''send-layout-cmd rivertile "main-ratio +0.05"'';
          "Super+Shift H" = ''send-layout-cmd rivertile "main-count -1"'';
          "Super+Shift L" = ''send-layout-cmd rivertile "main-count +1"'';
          "Super+Shift Left" = ''send-layout-cmd rivertile main-count  -1"'';
          "Super+Shift Right" = ''send-layout-cmd rivertile main-count  +1"'';
          # Super+Alt+{H,J,K,L} to move views
          "Super+Alt H" = "move left 100";
          "Super+Alt J" = "move down 100";
          "Super+Alt K" = "move up 100";
          "Super+Alt L" = "move right 100";

          # Super+Alt+Control+{H,J,K,L} to snap views to screen edges
          "Super+Alt+Control H" = "snap left";
          "Super+Alt+Control J" = "snap down";
          "Super+Alt+Control K" = "snap up";
          "Super+Alt+Control L" = "snap right";

          # Super+Alt+Shift+{H,J,K,L} to resize views
          "Super+Alt+Shift H" = "resize horizontal -100";
          "Super+Alt+Shift J" = "resize vertical 100";
          "Super+Alt+Shift K" = "resize vertical -100";
          "Super+Alt+Shift L" = "resize horizontal 100";

        } // (lib.zipAttrs (map
          (x_int:
            let
              pow = n: i:
                if i == 1 then n
                else if i == 0 then 1
                else n * pow n (i - 1);
              tags = toString (pow 2 (x_int - 1));
              x = toString x_int;

            in
            {
              "Super ${x}" = "set-focused-tags ${tags}";
              "Super+Shift ${x}" = "set-view-tags ${tags}";
              "Super+Control ${x}" = "toggle-focused-tags ${tags}";
              "Super+Shift+Control ${x}" = "toggle-view-tags ${tags}";
            }
          )
          (lib.range 1 9)))
        // {
          "Super 0" = "set-focused-tags 4294967295"; # $(((1 << 32) - 1))
          "Super+Shift 0" = "set-view-tags 4294967295"; # $(((1 << 32) - 1))
          # Super+Space to toggle float
          "Super Space" = "toggle-float";

          # Super+F to toggle fullscreen
          "Super F" = "toggle-fullscreen";

          # Super+{Up,Right,Down,Left} to change layout orientation
          "Super Up" = ''send-layout-cmd rivertile "main-location top"'';
          "Super Right" = ''send-layout-cmd rivertile "main-location right"'';
          "Super Down" = ''send-layout-cmd rivertile "main-location bottom"'';
          "Super Left" = ''send-layout-cmd rivertile "main-location left"'';
          # Control pulse audio volume with pamixer (https://github.com/cdemoulins/pamixer)
          "None XF86AudioRaiseVolume" = "spawn 'pamixer -i 5'";
          "None XF86AudioLowerVolume" = "spawn 'pamixer -d 5'";
          "None XF86AudioMute" = "spawn 'pamixer --toggle-mute'";

          # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
          "None XF86AudioMedia" = "spawn 'playerctl play-pause'";
          "None XF86AudioPlay" = "spawn 'playerctl play-pause'";
          "None XF86AudioPrev" = "spawn 'playerctl previous'";
          "None XF86AudioNext" = "spawn 'playerctl next'";

          # Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
          "None XF86MonBrightnessUp" = "spawn 'brightnessctl set +5%'";
          "None XF86MonBrightnessDown" = "spawn 'brightnessctl set 5%-'";
        }
        ;
      };
      map-pointer.normal = {
        # Super + Left Mouse Button to move views
        "Super BTN_LEFT" = "move-view";

        # Super + Right Mouse Button to resize views
        "Super BTN_RIGHT" = "resize-view";

        # Super + Middle Mouse Button to toggle float
        "Super BTN_MIDDLE" = "toggle-float";
      };
      border-color-focused = "0x7c6f64"; # bg4
      border-color-unfocused = "0x3c3836"; # bg1
      focus-follows-cursor = "normal";
      input = {
        "pointer-2362-628-PIXA3854:00_093A:0274_Touchpad" = "tap enabled";
      };
      xcursor-theme = "Adwaita";
      default-layout = "rivertile";
    };
    extraConfig = ''
      rivertile -view-padding 3 -outer-padding 3 &
    '';
  };
}
