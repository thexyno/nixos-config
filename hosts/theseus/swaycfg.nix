{ pkgs, config, inputs, ...}: {
home.packages = with pkgs; [
  slurp
  grim
  mako
  firefox
  light
  playerctl
  jq
  rofi
  swaylock
];
  home.file.".config/sway/config".text = ''
    set $mod Mod4
    set $term wezterm
    set $screenclip slurp | grim -g - ~/Images/screenshots/scrn-$(date +"%Y-%m-%d-%H-%M-%S").png
    set $screenshot grim ~/Images/screenshots/scrn-$(date +"%Y-%m-%d-%H-%M-%S").png
    set $menu rofi -m $(swaymsg -t get_outputs | jq 'map(select(.active) | .focused) | index(true)') -show drun -run-command 'swaymsg exec -- {cmd}'
    set $lock swaylock

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
set $ws1   1:
set $ws2   2:
set $ws3   3:3
set $ws4   4:4
set $ws5   5:5
set $ws6   6:6
set $ws7   7:7
set $ws8   8:8
set $ws9   9:9
set $ws0   10:10

exec --no-startup-id mako
input * {
    xkb_layout us
    xkb_variant colemak_dh_iso
    xkb_options caps:swapescape
}
bindsym $mod+Return exec $term
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

# Switch the current container between different layout styles
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# Make the current focus fullscreen
bindsym $mod+f fullscreen

# Toggle the current focus between tiling and floating mode
bindsym $mod+Shift+space floating toggle
# Swap focus between the tiling area and the floating area
bindsym $mod+space focus mode_toggle

# Move the currently focused window to the scratchpad
bindsym $mod+Shift+minus move scratchpad
# Show the next scratchpad window or hide the focused scratchpad window.
# If there are multiple scratchpad windows, this command cycles through them.
bindsym $mod+minus scratchpad show

# Modes
mode "resize" {
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px

    # return to default mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

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

  '';
}
