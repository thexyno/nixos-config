{ lib, pkgs, config, inputs, ... }:
let
  # backgroundImage = builtins.fetchurl {
    # url = "https://gruvbox-wallpapers.pages.dev/wallpapers/anime/wallhaven-2e2xyx.jpg";
    # sha256 = "1zw1a8x20bp9mn9lx18mxzgzvzi02ss57r4q1lc9f14fsmzphnlq";
  # };
  backgroundImage = "/home/ragon/Pictures/background.jpg";
in
{
  home.packages = with pkgs; [
    unstable.shikane
    helvum
    swaylock
    swayidle
    swaybg
    wlopm
    brightnessctl
    dconf
    pwvucontrol
    networkmanagerapplet
    libnotify
  ];

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "Adwaita-dark";
    style = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    configPackages = with pkgs; [ xdg-desktop-portal-gtk ];
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
    
* {
    /* `otf-font-awesome` is required to be installed for icons */
    font-family: "Source Sans Pro Nerd Font";
    font-size: 13px;
}

window#waybar {
/*    background-color: rgba(43, 48, 59, 0.5);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);*/
    color: #a89984;
    background-color: #282828;
/*    transition-property: background-color;
    transition-duration: .5s;*/
}

window#waybar.hidden {
    opacity: 0.2;
}

/*
window#waybar.empty {
    background-color: transparent;
}
window#waybar.solo {
    background-color: #FFFFFF;
}
*/

/*window#waybar.termite {
    background-color: #3F3F3F;
}

window#waybar.chromium {
    background-color: #000000;
    border: none;
}*/

#tags button {
    padding: 0 5px;
    background-color: #282828;
    color: #ebdbb2;
    /* Use box-shadow instead of border so the text isn't offset */
    box-shadow: inset 0 -3px transparent;
    /* Avoid rounded borders under each workspace name */
    border: none;
    border-radius: 0;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
/*    box-shadow: inset 0 -3px #fbf1c7;
*/
    background-color: #3c3836;
}

#tags button.focused {
/*    box-shadow: inset 0 -3px #fbf1c7;
*/
    background-color: #3c3836;
    color: #ebdbb2;
}

#tags button.occupied {
    color: #d3869b;
}
#tags button.urgent {
    background-color: #cc241d;
    color: #ebdbb2;
}

#mode {
    background-color: #64727D;
    border-bottom: 3px solid #fbf1c7;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#custom-poweroff,
#custom-suspend,
#mpd {
    padding: 0 5px;
    background-color: #282828;
    color: #ebdbb2;
}

#window,
#workspaces,
#tags  {
    margin: 0 4px;
}

/* If workspaces is the leftmost module, omit left margin */
.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

/* If workspaces is the rightmost module, omit right margin */
.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    color: #8ec07c;
}

#battery {
    color: #d3869b;
}

#battery.charging, #battery.plugged {
    color: #d3869b;
}

@keyframes blink {
    to {
        background-color: #fbf1c7;
        color: #df3f71;
    }
}

#battery.critical:not(.charging) {
    background-color: #282828;
    color: #d3869b;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

label:focus {
    background-color: #000000;
}

#backlight {
    color: #458588;
}

#temperature {
    color: #fabd2f;
}

#temperature.critical {
    background-color: #fbf1c7;
    color: #b57614;
}

#memory {
    color: #b8bb26;
}

#network {
    color: #fb4934;
}

#network.disconnected {
    background-color: #fbf1c7;
    color: #9d0006;
}

/*#disk {
    background-color: #964B00;
}*/

#pulseaudio {
    color: #fe8019;
}

#pulseaudio.muted {
    background-color: #fbf1c7;
    color: #af3a03;
}

#tray {
}

#tray > .needs-attention {
    background-color: #fbf1c7;
    color: #3c3836;
}

#idle_inhibitor {
    background-color: #282828;
    color: #ebdbb2;
}

#idle_inhibitor.activated {
    background-color: #fbf1c7;
    color: #3c3836;
}

#custom-media {
    background-color: #66cc99;
    color: #2a5c45;
    min-width: 100px;
}

#custom-media.custom-spotify {
    background-color: #66cc99;
}

#custom-media.custom-vlc {
    background-color: #ffa000;
}

#mpd {
    background-color: #66cc99;
    color: #2a5c45;
}

#mpd.disconnected {
    background-color: #f53c3c;
}

#mpd.stopped {
    background-color: #90b1b1;
}

#mpd.paused {
    background-color: #51a37a;
}

#language {
    background: #00b093;
    color: #740864;
    padding: 0 5px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state {
    background: #97e1ad;
    color: #000000;
    padding: 0 0px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state > label {
    padding: 0 5px;
}

#keyboard-state > label.locked {
    background: rgba(0, 0, 0, 0.2);
}
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 15;
        modules-left = [ "river/tags" "river/layout" "tray"];
        modules-center = [ "river/window" ];
        modules-right = [  "wireplumber" "upower" "backlight" "cpu" "temperature" "memory" "disk" "custom/tailscale" "network" "clock" ];
        "river/window" = {
          max-length = 40;
        };
        wireplumber = {
          "format" = "{volume}% {icon}";
          "format-muted" = "";
          "on-click" = "${pkgs.pwvucontrol}/bin/pwvucontrol";
          "on-right-click" = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "format-icons" = [ "" "" "" ];
        };
        "backlight" = {
          "device" = "amdgpu_bl1";
          "format" = "{percent}% {icon}";
          "format-icons" = [ "" "" ];
          "on-scroll-up" = "${pkgs.brightnessctl}/bin/brightnessctl s +10";
          "on-scroll-down" = "${pkgs.brightnessctl}/bin/brightnessctl s 10-";
        };
        "cpu" = {
          "interval" = 10;
          "format" = "{:0.0f}% ";
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
        "custom/tailscale" = {
          exec = pkgs.writeScript "tailscaleWaybar.sh" ''
            #!${pkgs.bash}/bin/bash
            TAILNET=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -j '.MagicDNSSuffix')
            
            echo "''${''${TAILNET%.ts.net}:(-15)}"
          '';
          interval = 30;
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
        normal =
          let
            scrn = pkgs.writeScript "scrn.sh" ''
              #!${pkgs.bash}/bin/bash
              IMG_FILE=~/Images/screenshots/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png
              ${pkgs.grim}/bin/grim $IMG_FILE
              ${pkgs.wl-clipboard}/bin/wl-copy < $IMG_FILE
              ${pkgs.libnotify}/bin/notify-send -i $IMG_FILE -e -t 10000 "Screenshot Saved" $IMG_FILE
            '';
            slurpscrn = pkgs.writeScript "scurpscrn.sh" ''
              #!${pkgs.bash}/bin/bash
              IMG_FILE=~/Images/screenshots/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png
              ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - $IMG_FILE
              ${pkgs.wl-clipboard}/bin/wl-copy < $IMG_FILE
              ${pkgs.libnotify}/bin/notify-send -i $IMG_FILE -e -t 10000 "Screenshot Saved" $IMG_FILE
            '';
          in
          {
            "Super+Alt 4" = "spawn '${slurpscrn}'";
            "Super+Alt 1" = "spawn '${scrn}'";
            "Super+Shift Space" = "spawn 'rofi -show drun'";
            "Super+Shift Return" = "spawn wezterm";
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
            "Super+Control Period" = "send-to-output -current-tags right";
            "Super+Control Comma" = "send-to-output -current-tags left";
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
      keyboard-layout = "eu";
      xcursor-theme = "Adwaita";
      default-layout = "rivertile";
    };
    extraConfig = ''
      rivertile -view-padding 3 -outer-padding 3 &
      swayidle \
          timeout 300 'swaylock -i ${backgroundImage}' \
          timeout 600 'wlopm --off \*' resume 'wlopm --on \*' \
          before-sleep 'swaylock -i ${backgroundImage}' &
      swaybg -i ${backgroundImage} &
      shikane &
      nm-applet &
    '';
  };
  services.wired = {
    enable = true;
    config = ./wired.ron;
  };
}
