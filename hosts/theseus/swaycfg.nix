{ pkgs, config, inputs, ... }: {
  # imports = [ inputs.ironbar.homeManagerModules.default ];
  home.packages = with pkgs; [
    slurp
    grim
    # mako
    firefox
    # light installed via programs.light
    playerctl
    jq
    rofi
    # inputs.swaymonad.defaultPackage.x86_64-linux
    swaylock
  ];
  # programs.ironbar = {
  #   enable = false;
  #   style = ''
  #     @define-color color_bg #282828;
  #     @define-color color_bg_dark #3c3836;
  #     @define-color color_border #665c54;
  #     @define-color color_border_active #7c6f64;
  #     @define-color color_text #ebdbb2;
  #     @define-color color_urgent #cc241d;
  #     * {
  #         font-family: Source Sans Pro Nerd Font, sans-serif;
  #         font-size: 15px;
  #         border: none;
  #         border-radius: 0;
  #     }
      
  #     box, menubar, button {
  #         background-color: @color_bg;
  #         background-image: none;
  #         box-shadow: none;
  #     }
      
  #     button, label {
  #         color: @color_text;
  #     }
      
  #     button:hover {
  #         background-color: @color_bg_dark;
  #     }
      
  #     scale trough {
  #         min-width: 1px;
  #         min-height: 2px;
  #     }
      
  #     /* #bar {
  #         border-top: 1px solid @color_border;
  #     } */
      
  #     .popup {
  #         border: 1px solid @color_border;
  #         padding: 1em;
  #     }
  #   '';
  #   config = {
  #     position = "top";
  #     height = 20;
  #     start = [
  #       { type = "workspaces"; }
  #       { type = "sway_mode"; }
  #     ];
  #     center = [
  #       {
  #         type = "focused";
  #         show_icon = true;
  #         show_title = true;
  #         icon_size = 10;
  #         truncate = "end";
  #       }
  #     ];
  #     end = [
  #       { type = "music"; player_name = "mpris"; }
  #       {
  #         type = "volume";
  #         icons = {
  #           volume_high = "󰕾";
  #           volume_medium = "󰖀";
  #           volume_low = "󰕿";
  #           muted = "󰝟";
  #         };
  #         format = "{icon} {percentage}%";
  #         max_volume = 100;
  #       }
  #       {
  #         type = "upower";
  #         format = "{icon} {percentage}%";
  #       }
  #       {
  #         type = "sys_info";
  #         format = [
  #           "  {cpu_percent}%"
  #           " {temp_c:k10temp-Tctl}°C"
  #           " {memory_used}/{memory_total}GB"
  #           "󰋊 {disk_used:/persistent}/{disk_total:/persistent}GB"
  #           "󰓢 {net_down:wlan0}/{net_up:wlan0} Mbps"
  #           # "󰖡 {load_average:1} | {load_average:5} | {load_average:15}"
  #         ];
  #         interval = {
  #           "cpu" = 1;
  #           "disks" = 300;
  #           "memory" = 30;
  #           "networks" = 3;
  #           "temps" = 5;
  #         };
  #       }
  #       {
  #         type = "clock";
  #         format = "%Y-%m-%dT%H:%M:%S%z";
  #       }
  #     ];
  #   };
  # };

  # TODO: change to home-manager module somehow
  home.file.".config/sway/config".text = ''
        set $mod Mod4
        set $term wezterm
        set $screenclip slurp | grim -g - ~/Images/screenshots/scrn-$(date +"%Y-%m-%d-%H-%M-%S").png
        set $screenshot grim ~/Images/screenshots/scrn-$(date +"%Y-%m-%d-%H-%M-%S").png
        set $menu rofi -show drun -run-command 'swaymsg exec -- {cmd}'
        set $lock swaylock -c 000000

        exec --no-statup-id ${pkgs.kanshi}/bin/kanshi

        set $cl_high #009ddc
        set $cl_indi #d9d8d8
        set $cl_back #231f20
        set $cl_fore #d9d8d8
        set $cl_urge #ee2e24
        # Colors                border   bg       text     indi     childborder
        client.focused          $cl_high $cl_high $cl_fore $cl_indi $cl_high
        client.focused_inactive $cl_back $cl_back $cl_fore $cl_back $cl_back
        client.unfocused        $cl_back $cl_back $cl_fore $cl_back $cl_back
        client.urgent           $cl_urge $cl_urge $cl_fore $cl_urge $cl_urge

        # workspaces
        set $ws1   1:1
        set $ws2   2:2
        set $ws3   3:3
        set $ws4   4:4
        set $ws5   5:5
        set $ws6   6:6
        set $ws7   7:7
        set $ws8   8:8
        set $ws9   9:9
        set $ws0   10:10

        exec --no-startup-id mako
        exec --no-startup-id ironbar
        input * {
            xkb_layout eu
        }
        input 12972:6:FRMW0004:00_32AC:0006_Consumer_Control {
            xkb_layout us
            xkb_variant colemak_dh_iso
            xkb_options caps:escape
        }
        input type:touchpad {
          tap enabled
        }
        bindsym $mod+Shift+Return exec $term
        bindsym $mod+Space exec $menu
        bindsym $mod+Print exec $screenshot
        bindsym $mod+Shift+Print exec $screenclip
        bindsym $mod+Shift+q kill
        bindsym $mod+Shift+c reload
        # Brightness controls
        bindsym --locked XF86MonBrightnessUp exec --no-startup-id light -A 10
        bindsym --locked XF86MonBrightnessDown exec --no-startup-id light -U 10
        # Multimedia
        bindsym --locked XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') +5%
        bindsym --locked XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') -5%
        bindsym --locked XF86AudioMute exec --no-startup-id pactl set-sink-mute $(pacmd list-sinks |awk '/* index:/{print $3}') toggle
        bindsym --locked XF86AudioPlay exec playerctl play-pause
        bindsym --locked XF86AudioNext exec playerctl next
        bindsym --locked XF86AudioPrev exec playerctl previous

        # Idle configuration
        exec swayidle \
            timeout 300 'exec $lock' \
            timeout 600 'swaymsg "output * dpms off"' \
            after-resume 'swaymsg "output * dpms on"' \
            before-sleep 'exec $lock'
            # switch to workspace
        bindsym $mod+1   workspace $ws1
        bindsym $mod+2   workspace $ws2
        bindsym $mod+3   workspace $ws3
        bindsym $mod+4   workspace $ws4
        bindsym $mod+5   workspace $ws5
        bindsym $mod+6   workspace $ws6
        bindsym $mod+7   workspace $ws7
        bindsym $mod+8   workspace $ws8
        bindsym $mod+9   workspace $ws9
        bindsym $mod+0   workspace $ws0

        # move focused container to workspace
        bindsym $mod+Shift+1    move container to workspace $ws1
        bindsym $mod+Shift+2    move container to workspace $ws2
        bindsym $mod+Shift+3    move container to workspace $ws3
        bindsym $mod+Shift+4    move container to workspace $ws4
        bindsym $mod+Shift+5    move container to workspace $ws5
        bindsym $mod+Shift+6    move container to workspace $ws6
        bindsym $mod+Shift+7    move container to workspace $ws7
        bindsym $mod+Shift+8    move container to workspace $ws8
        bindsym $mod+Shift+9    move container to workspace $ws9
        bindsym $mod+Shift+0    move container to workspace $ws0
        # Layout stuff:

        # Make the current focus fullscreen
        bindsym $mod+Shift+f fullscreen

        # Toggle the current focus between tiling and floating mode
        bindsym $mod+Shift+space floating toggle
        # Swap focus between the tiling area and the floating area
        # bindsym $mod+f focus mode_toggle

        # Move the currently focused window to the scratchpad
        bindsym $mod+Shift+minus move scratchpad
        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        bindsym $mod+minus scratchpad show

        set $mode_system System: (l) lock, (e) logout, (s) suspend, (r) reboot, (S) shutdown, (R) UEFI
        mode "$mode_system" {
            bindsym l exec $lock, mode "default"
            bindsym e exit
            bindsym s exec --no-startup-id systemctl suspend, mode "default"
            bindsym r exec --no-startup-id systemctl reboot, mode "default"
            bindsym Shift+s exec --no-startup-id systemctl poweroff -i, mode "default"
            bindsym Shift+r exec --no-startup-id systemctl reboot --firmware-setup, mode "default"

            # return to default mode
            bindsym Return mode "default"
            bindsym Escape mode "default"
        }
        bindsym $mod+Shift+e mode "$mode_system"

        # exec_always "pkill -f 'python3? .+/swaymonad.py';  swaymonad"
    bindsym $mod+Return nop promote_window

    bindsym $mod+j nop focus_next_window
    bindsym $mod+k nop focus_prev_window
    bindsym $mod+Down nop focus_next_window
    bindsym $mod+Up nop focus_prev_window

    bindsym $mod+Shift+Left nop move left
    bindsym $mod+Shift+Down nop move down
    bindsym $mod+Shift+Up nop move up
    bindsym $mod+Shift+Right nop move right

    bindsym $mod+Shift+j nop swap_with_next_window
    bindsym $mod+Shift+k nop swap_with_prev_window

    bindsym $mod+x nop reflectx
    bindsym $mod+y nop reflecty
    bindsym $mod+t nop transpose

    bindsym $mod+f nop fullscreen

    bindsym $mod+Comma nop increment_masters
    bindsym $mod+Period nop decrement_masters

    mode "resize" {
      bindsym Left resize shrink width 10px
      bindsym Down resize grow height 10px
      bindsym Up resize shrink height 10px
      bindsym Right resize grow width 10px

      bindsym Shift+Left nop resize_master shrink width 10px
      bindsym Shift+Down nop resize_master grow height 10px
      bindsym Shift+Up nop resize_master shrink height 10px
      bindsym Shift+Right nop resize_master grow width 10px

      # bindsym n resize set width (n-1/n)
      bindsym 2 resize set width 50ppt  # 1/2, 1/2
      bindsym 3 resize set width 66ppt  # 2/3, 1/3
      bindsym 4 resize set width 75ppt  # 3/4, 1/4

      bindsym Shift+2 nop resize_master set width 50ppt
      bindsym Shift+3 nop resize_master set width 66ppt
      bindsym Shift+4 nop resize_master set width 75ppt

      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"

    mode "layout" {
      bindsym t nop set_layout tall
      bindsym 2 nop set_layout 2_col
      bindsym 3 nop set_layout 3_col
      bindsym n nop set_layout nop

      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    # nop set_layout 2_col
    bindsym $mod+l mode "layout"

    mouse_warping container
    focus_wrapping no

  '';
}
