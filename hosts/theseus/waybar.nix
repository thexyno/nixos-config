{ pkgs, config, lib, ... }:
let
  cfg = config.xyno.desktop.waybar;
  waybarConf = pkgs.writeText "waybar.conf" ''
    font=Source Sans Pro Nerd Font
    background-color=#1d2021ff
    border-color=#3c3836FF
    text-color=#ebdbb2ff
    progress-color=over #928374FF
  '';
in
{
  options.xyno.desktop.waybar.enable = lib.mkEnableOption "enable mako notification daemon";
  options.xyno.desktop.waybar.wantedBy = lib.mkOption {
    type = lib.types.str;
    default = "niri.service";
  };
  options.xyno.desktop.waybar.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.waybar;
  };
  options.xyno.desktop.waybar.mode = lib.mkOption {
    type = lib.types.str;
    default = "niri";
  };
  config = lib.mkIf cfg.enable {
    programs.waybar.enable = true;
    environment.etc."xdg/waybar/config".text = builtins.toJSON {
      mainBar = {
        layer = "top";
        position = "top";
        height = 15;
        modules-left = (lib.mkIf (cfg.mode == "river") [ "river/tags" "river/layout" "river/window" ])
         ++ (lib.mkIf (cfg.mode == "niri") [ "niri/workspaces" "niri/window" ]);
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
    environment.etc."xdg/waybar/style.css".text = ''
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
  };
}
