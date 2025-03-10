{ pkgs, config, lib, ... }:
let
  floatingAppids = [
    "floating-alacritty"
    "org.pulseaudio.pavucontrol"
    "KeePassXC"
    "org.gnome.NautilusPreviewer"
  ];
  matchFloat = lib.concatStringSep "\n" (map (x: ''
    window-rule {
      match app-id="${x}"
      open-floating true
      open-focused true
    }
  '') floatingAppids);
in
{
  imports = [
    ./waybar.nix
    ./mako.nix
  ];
  xyno.desktop = {
    waybar.enable = true;
    mako.enable = true;
  };
  programs.niri.enable = true;
  environment.etc."niri/config.kdl".text = ''
    screenshot-path "~/Pictures/screenshots/screenshot-%Y-%m-%d %H-%M-%S.png"
    input {
      workspace-auto-back-and-forth
      focus-follows-mouse max-scroll-amount="10%"
      touchpad {
        tap
      }
    }
    // autogenerated from here on
    ${matchFloat}
  '';
}
