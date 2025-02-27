{ lib, pkgs, config, inputs, ... }:
let
  # backgroundImage = builtins.fetchurl {
  # url = "https://gruvbox-wallpapers.pages.dev/wallpapers/anime/wallhaven-2e2xyx.jpg";
  # sha256 = "1zw1a8x20bp9mn9lx18mxzgzvzi02ss57r4q1lc9f14fsmzphnlq";
  # };
  setRandomBackground = pkgs.writeScript "setBackground.sh" ''
    #!/${pkgs.bash}/bin/bash
    while true; do
      FILENAME=''$(${pkgs.findutils}/bin/find /home/ragon/Pictures/backgrounds -type f | ${pkgs.coreutils}/bin/shuf -n 1)
      ${pkgs.swaybg}/bin/swaybg -i $FILENAME -m fill &
      PID=$!
      sleep 1200
      kill $PID
    done
  '';
  backgroundImage = "/home/ragon/Pictures/background.jpg";
  pow = n: i:
    if i == 1 then n
    else if i == 0 then 1
    else n * pow n (i - 1);
  tag = n: toString (pow 2 (n - 1));
  scratchTag = tag 20;
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
    playerctl
    pwvucontrol
    # networkmanagerapplet
    mako
    impala
    # iwgtk
    libnotify
  ];

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  home.file.".config/mako/config".text = ''
    font=Source Sans Pro Nerd Font
    background-color=#1d2021ff
    border-color=#3c3836FF
    text-color=#ebdbb2ff
    progress-color=over #928374FF
  '';

  gtk = {
    enable = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    # platformTheme.name = "Adwaita-dark";
    platformTheme.name = "Fusion";
    style = {
      name = "Fusion";
      # package = pkgs.adwaita-qt;
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
    
* {
    /* `otf-font-awesome` is required to be installed for icons */
    font-family: "Source Sans Pro Nerd Font";
    font-size: 12px;
}

window#waybar {
/*    background-color: rgba(43, 48, 59, 0.5);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);*/
    color: #a89984;
    background-color: #1d2021;
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
    padding: 0 2px;
    background-color: #1d2021;
    color: #ebdbb2;
    /* Use box-shadow instead of border so the text isn't offset */
    box-shadow: inset 0 -3px transparent;
    /* Avoid rounded borders under each workspace name */
    border: none;
    border-radius: 0;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
#tags button:hover {
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
    padding: 0 2px;
    background-color: #1d2021;
    color: #ebdbb2;
}

#window,
#workspaces,
#tags  {
    margin: 0 2px;
}

/* If workspaces is the leftmost module, omit left margin */
.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

/* If workspaces is the rightmost module, omit right margin */
.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}


#battery {
    color: #d3869b;
}

#battery.charging, #battery.plugged {
    color: #98971a;
}

@keyframes blink {
    to {
        background-color: #fbf1c7;
        color: #df3f71;
    }
}

#battery.critical:not(.charging) {
    background-color: #1d2021;
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
    color: #FCF434; /* enby yellow */
}
#disk {
    color: #FFFFFF; /* enby white */
}
#network {
    color: #b8bb26; /* enby green */
}
#clock {
    color: #9C59D1; /* enby purple */
    /*color: #2C2C2C; enby black */
}


#network.disconnected {
    background-color: #fbf1c7;
    color: #9d0006;
}


#wireplumber {
    color: #fe8019;
}

#tray {
}

#tray > .needs-attention {
    background-color: #fbf1c7;
    color: #3c3836;
}

#idle_inhibitor {
    background-color: #1d2021;
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
        modules-left = [ "river/tags" "river/layout" "river/window" ];
        modules-right = [ "tray" "power_profiles_daemon" "idle_inhibitor" "wireplumber" "battery" "backlight" "cpu" "temperature" "memory" "disk" "custom/tailscale" "network" "clock" ];
        "river/window" = {
          max-length = 40;
        };
        wireplumber = {
          "format" = "{icon}  {volume}%";
          "format-muted" = "  MUTE";
          # "on-click" = "${pkgs.pwvucontrol}/bin/pwvucontrol";
          "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
          "on-click-right" = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "format-icons" = [ "" "" "" ];
        };
        "backlight" = {
          "device" = "amdgpu_bl1";
          "format" = "{icon} {percent}%";
          "format-icons" = [ "󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠" ];
          "on-scroll-up" = "${pkgs.brightnessctl}/bin/brightnessctl s +10";
          "on-scroll-down" = "${pkgs.brightnessctl}/bin/brightnessctl s 10-";
        };
        "idle_inhibitor" = {
          format = "{icon} ";
          format-icons = {
            "activated" = "󰅶";
            "deactivated" = "󰾪";
          };
        };
        battery = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon}  {capacity}%";
          "format-icons" = [ "" "" "" "" "" ];
          "tooltip-format" = "Capacity: {capacity}%\nPower Draw: {power:0.2f}W\n{timeTo}\nCycles: {cycles}";
          "max-length" = 25;
        };
        "cpu" = {
          "interval" = 10;
          "format" = "  {:0.0f}%";
          "max-length" = 10;
        };
        "temperature" = {
          "format" = " {temperatureC}°C";
        };
        memory = {
          interval = 30;
          format = " {used:0.0f}/{total:0.0f}GB";
        };
        clock = {
          interval = 1;
          format = "{:%Y-%m-%dT%H:%M:%S%z}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "mode" = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ecc6d9'><b>{}</b></span>";
              "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
              "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          "actions" = {
            "on-click-right" = "mode";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };
        disk = {
          format = "󰋊 {specific_used:0.0f}/{specific_total:0.0f}GB";
          unit = "GB";
          path = "/persistent";
        };
        # "custom/tailscale" = {
        #   exec = pkgs.writeScript "tailscaleWaybar.sh" ''
        #     #!${pkgs.bash}/bin/bash
        #     TAILNET=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -j '.MagicDNSSuffix')
            
        #     echo "''${''${TAILNET%.ts.net}:(-15)}"
        #   '';
        #   interval = 30;
        # };
        "network" = {
          "on-click" = "${pkgs.alacritty}/bin/alacritty --class floating-alacritty -e ${pkgs.impala}/bin/impala";
          "format" = "{ifname}";
          "format-wifi" = "󰖩 {essid}";
          "format-ethernet" = "󰈀 {ifname}";
          "format-disconnected" = "󰖪";
          "tooltip-format" = "{ifname} via {gwaddr}\n{ipaddr}/{cidr}";
          "tooltip-format-wifi" = "{essid} ({signaldBm} dBm) {frequency} GHz\n{ipaddr}/{cidr}";
          "tooltip-format-ethernet" = "{ifname}\n{ipaddr}/{cidr}";
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
            "Super+Shift A" = "spawn alacritty";
            "Super+Shift F" = "spawn nautilus";
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
            "Super+Shift Left" = ''send-layout-cmd rivertile "main-count  -1"'';
            "Super+Shift Right" = ''send-layout-cmd rivertile "main-count  +1"'';
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
            "Super P" = "toggle-focused-tags ${scratchTag}";
            "Super+Shift P" = "set-view-tags ${scratchTag}";
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
      spawn-tagmask = "4293918719"; # (( ((1 << 32) - 1) ^ (1 << 20) )) all but scratch tag
      rule-add = {
        "-title 'Picture-in-Picture'" = "float";
        "-app-id 'floating-alacritty'" = "float";
        "-app-id 'org.pulseaudio.pavucontrol'" = "float";
        "-app-id 'KeePassXC'" = "float";
        "-app-id 'org.gnome.NautilusPreviewer'" = "float";
        "-app-id 'Signal'" = "tags ${tag 9}"; # signal
        "-app-id 'Element'" = "tags ${tag 9}"; # cinny
        "-app-id 'FFPWA-01JHNYASHBQB122KMCDPEZ65JA'" = "tags ${tag 9}"; # yt music
        "-app-id 'org.gnome.evolution'" = "tags ${tag 8}"; # evolution
        "-app-id 'obsidian'" = "tags ${tag 1}"; # obsidian
        "-app-id 'KeePassXC' " = "tags ${scratchTag}"; 
      };
    };
    extraConfig = ''
      export XDG_CURRENT_DESKTOP=river
      export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
      rivertile -view-padding 0 -outer-padding 0 &
      swayidle \
          timeout 300 'swaylock -i ${backgroundImage}' \
          timeout 600 'wlopm --off \*' resume 'wlopm --on \*' \
          before-sleep 'swaylock -i ${backgroundImage}' &
      # swaybg -i ${backgroundImage} &
      ${setRandomBackground} &
      shikane &
      ${pkgs.mako}/bin/mako &
      # iwgtk likes to crash when restarting iwd
      # (while true; do iwgtk -i; sleep 10; done) &
      # now autostarting stuff thats always open anyways
      obsidian &
      signal-desktop &
      element-desktop &
      evolution &
      # ${pkgs.appimage-run}/bin/appimage-run /home/ragon/AppImages/KeePassXC-2.8.0-snapshot-x86_64.AppImage &
      keepassxc &
    '';
  };
  # services.wired = {
  #   enable = true;
  #   config = ./wired.ron;
  # };
}
