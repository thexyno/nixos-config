{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf (cfg.enable && config.ragon.gui.river.enable) {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
    {
      programs.alacritty = {
        enable = true;
        settings = {
          font.normal.family = "JetBrainsMono Nerd Font";
          colors.primary = {
            background = "#282828";
            foreground = "#1bf1c7";
          };

        };


      };
      programs.mako = {
        enable = true;
        borderColor = "#689d6aFF";
        backgroundColor = "#1d2021FF";
        font = "JetBrainsMono Nerd Font";
        layer = "overlay";
      };
      programs.waybar = {
        enable = true;
        settings = [ {
          layer = "top";
          position = "top";
          height = 27;
          modules-left = [ "river/tags" ];
          modules-right = [ "pulseaudio" "network" "battery" "clock" ];
          modules = {
            "clock" = {
              interval = 1;
              format = "{:%F %T}";
              max-length = 25;
            };
            "battery" = {
              format-discharging = "{icon} {capacity}% ({time})";
              format-charging = " {capacity}% ({time})";
              format-unknown = "{icon} {capacity}%";
              format-icons = ["" "" "" "" "" "" "" "" "" ""];
            };
            "network" = {
              format-wifi = "直 {essid} : {signalStrength}%";
              format-ethernet = "{ifname}";
              format-Disconnected = "Disconnected";
            };
            "pulseaudio" = {
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}%";
              format-muted = "ﱝ";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["奄" "奔" "墳"];
              };
            };
          };
        } ];
        style = ''
          * {
              border: none;
              border-radius: 0px;
              font-family: "JetBrainsMono Nerd Font";
              font-size: 12px;
              min-height: 0;
              color: #ebdbb2;
          }
          
          window#waybar {
              border-bottom-style: inset;
              border-bottom: 0px solid #689d6a;
              background: #1d2021;
          }
          
          #clock, #window { 
              font-weight: 800;
          }
          
          /* River Buttons */
          #tags button.urgent{
              background: #cc241d;
          }
          #tags button.occupied{
              background: #3c3836;
          }
          #tags button.focused {
              color: #d79921;
          }
          
          #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #mode, #idle_inhibitor {
              padding: 0 5px;
              margin: 0 10px;
          }

          
          
          #idle_inhibitor {
              padding: 0 10px;
          }
          
          #idle_inhibitor.activated {
              background-color: #689d6a;
              color: #1d2021;
          }
          
          #clock {
              margin: 0;
              color: #fabd2f;
              border-bottom: 4px solid #fabd2f;
          }
          
          #network.disconnected {
              color: #cc241d;
              border-bottom: 4px solid #cc241d;
          }
          
          
          #pulseaudio.muted {
              padding: 0 20px;
              color: #cc241d;
              border-bottom: 4px solid #cc241d;
          }
        '';
      };
      home.file.".config/river/init" = { executable = true; text = ''
        #!${pkgs.bash}/bin/bash
        set -x

        # This is the example configuration file for river.
        #
        # If you wish to edit this, you will probably want to copy it to
        # $XDG_CONFIG_HOME/river/init or $HOME/.config/river/init first.
        #
        # See the river(1), riverctl(1), and rivertile(1) man pages for complete
        # documentation.
        
        # Use the "logo" key as the primary modifier
        mod="Mod4"
        
        # Mod+Shift+Return to start an instance of foot (https://codeberg.org/dnkl/foot)
        riverctl map normal $mod+Shift Return spawn ${pkgs.alacritty}/bin/alacritty
        riverctl map normal $mod P spawn '${pkgs.fuzzel}/bin/fuzzel -f "JetBrainsMono Nerd Font" -b "1d2021ff" -T alacritty'
        
        # Mod+Q to close the focused view
        riverctl map normal $mod+Shift Q close
        
        # Mod+E to exit river
        riverctl map normal $mod+Shift E spawn ${pkgs.wlogout}/bin/wlogout
        
        # Mod+J and Mod+K to focus the next/previous view in the layout stack
        riverctl map normal $mod J focus-view next
        riverctl map normal $mod K focus-view previous
        
        # Mod+Shift+J and Mod+Shift+K to swap the focused view with the next/previous
        # view in the layout stack
        riverctl map normal $mod+Shift J swap next
        riverctl map normal $mod+Shift K swap previous
        
        # Mod+Period and Mod+Comma to focus the next/previous output
        riverctl map normal $mod Period focus-output next
        riverctl map normal $mod Comma focus-output previous
        
        # Mod+Shift+{Period,Comma} to send the focused view to the next/previous output
        riverctl map normal $mod+Shift Period send-to-output next
        riverctl map normal $mod+Shift Comma send-to-output previous
        
        # Mod+Return to bump the focused view to the top of the layout stack
        riverctl map normal $mod Return zoom
        
        # Mod+H and Mod+L to decrease/increase the main ratio of rivertile(1)
        riverctl map normal $mod H send-layout-cmd rivertile "main-ratio -0.05"
        riverctl map normal $mod L send-layout-cmd rivertile "main-ratio +0.05"
        
        # Mod+Shift+H and Mod+Shift+L to increment/decrement the main count of rivertile(1)
        riverctl map normal $mod+Shift H send-layout-cmd rivertile "main-count +1"
        riverctl map normal $mod+Shift L send-layout-cmd rivertile "main-count -1"
        
        # Mod+Alt+{H,J,K,L} to move views
        riverctl map normal $mod+Mod1 H move left 100
        riverctl map normal $mod+Mod1 J move down 100
        riverctl map normal $mod+Mod1 K move up 100
        riverctl map normal $mod+Mod1 L move right 100
        
        # Mod+Alt+Control+{H,J,K,L} to snap views to screen edges
        riverctl map normal $mod+Mod1+Control H snap left
        riverctl map normal $mod+Mod1+Control J snap down
        riverctl map normal $mod+Mod1+Control K snap up
        riverctl map normal $mod+Mod1+Control L snap right
        
        # Mod+Alt+Shif+{H,J,K,L} to resize views
        riverctl map normal $mod+Mod1+Shift H resize horizontal -100
        riverctl map normal $mod+Mod1+Shift J resize vertical 100
        riverctl map normal $mod+Mod1+Shift K resize vertical -100
        riverctl map normal $mod+Mod1+Shift L resize horizontal 100
        
        # Mod + Left Mouse Button to move views
        riverctl map-pointer normal $mod BTN_LEFT move-view
        
        # Mod + Right Mouse Button to resize views
        riverctl map-pointer normal $mod BTN_RIGHT resize-view

        # Focus follows cursor
        riverctl focus-follows-cursor normal
        
        for i in $(seq 1 9)
        do
            tags=$((1 << ($i - 1)))
        
            # Mod+[1-9] to focus tag [0-8]
            riverctl map normal $mod $i set-focused-tags $tags
        
            # Mod+Shift+[1-9] to tag focused view with tag [0-8]
            riverctl map normal $mod+Shift $i set-view-tags $tags
        
            # Mod+Ctrl+[1-9] to toggle focus of tag [0-8]
            riverctl map normal $mod+Control $i toggle-focused-tags $tags
        
            # Mod+Shift+Ctrl+[1-9] to toggle tag [0-8] of focused view
            riverctl map normal $mod+Shift+Control $i toggle-view-tags $tags
        done
        
        # Mod+0 to focus all tags
        # Mod+Shift+0 to tag focused view with all tags
        all_tags=$(((1 << 32) - 1))
        riverctl map normal $mod 0 set-focused-tags $all_tags
        riverctl map normal $mod+Shift 0 set-view-tags $all_tags
        
        # Mod+Space to toggle float
        riverctl map normal $mod Space toggle-float
        
        # Mod+F to toggle fullscreen
        riverctl map normal $mod F toggle-fullscreen
        
        # Mod+{Up,Right,Down,Left} to change layout orientation
        riverctl map normal $mod Up    send-layout-cmd rivertile "main-location top"
        riverctl map normal $mod Right send-layout-cmd rivertile "main-location right"
        riverctl map normal $mod Down  send-layout-cmd rivertile "main-location bottom"
        riverctl map normal $mod Left  send-layout-cmd rivertile "main-location left"
        
        # Declare a passthrough mode. This mode has only a single mapping to return to
        # normal mode. This makes it useful for testing a nested wayland compositor
        riverctl declare-mode passthrough
        
        # Mod+F11 to enter passthrough mode
        riverctl map normal $mod F11 enter-mode passthrough
        
        # Mod+F11 to return to normal mode
        riverctl map passthrough $mod F11 enter-mode normal
        
        # Various media key mapping examples for both normal and locked mode which do
        # not have a modifier
        for mode in normal locked
        do
            # Eject the optical drive
            riverctl map $mode None XF86Eject spawn 'eject -T'
        
            # Control pulse audio volume with pamixer (https://github.com/cdemoulins/pamixer)
            riverctl map $mode None XF86AudioRaiseVolume  spawn '${pkgs.pulsemixer}/bin/pulsemixer +5'
            riverctl map $mode None XF86AudioLowerVolume  spawn '${pkgs.pulsemixer}/bin/pulsemixer -5'
            riverctl map $mode None XF86AudioMute         spawn '${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute'
        
            # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
            riverctl map $mode None XF86AudioMedia spawn '${pkgs.playerctl}/bin/playerctl play-pause'
            riverctl map $mode None XF86AudioPlay  spawn '${pkgs.playerctl}/bin/playerctl play-pause'
            riverctl map $mode None XF86AudioPrev  spawn '${pkgs.playerctl}/bin/playerctl previous'
            riverctl map $mode None XF86AudioNext  spawn '${pkgs.playerctl}/bin/playerctl next'
        
            # Control screen backlight brighness with light (https://github.com/haikarainen/light)
            riverctl map $mode None XF86MonBrightnessUp   spawn '${pkgs.light}/bin/light -A 5'
            riverctl map $mode None XF86MonBrightnessDown spawn '${pkgs.light}/bin/light -U 5'
        done
        
        # Set background and border color
        riverctl background-color 0x282828
        riverctl border-color-focused 0x504945
        riverctl border-color-unfocused 0x3c3836
        
        # Set repeat rate
        riverctl set-repeat 50 300
        
        # Set app-ids of views which should float
        riverctl float-filter-add "float"
        riverctl float-filter-add "popup"
        
        # Set app-ids of views which should use client side decorations
        riverctl csd-filter-add "gedit"

        for input in ''$(riverctl list-inputs | sed -n '/pointer/{x;p;d;}; x'); do
          riverctl input $input tap enabled
        done

        waybar &
        mako &

        # Set and exec into the default layout generator, rivertile.
        # River will send the process group of the init executable SIGTERM on exit.
        riverctl default-layout rivertile
        exec rivertile -view-padding 0 -outer-padding 0
      ''; };
    };
  };
}
