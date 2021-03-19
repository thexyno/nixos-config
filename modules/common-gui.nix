{ config, lib, pkgs, ... }:
let
  sources = import ../nix/sources.nix;
  cfg = config.ragon.gui;
in
{
  options.ragon.gui.enable = lib.mkEnableOption "Enables ragons Gui stuff";
  config = lib.mkIf cfg.enable {
    # Set up default fonts
    fonts.enableDefaultFonts = true;
    fonts.enableGhostscriptFonts = true;

    # Configure fontconfig to actually use more of Noto Color Emoji in
    # alacritty.
    fonts.fontconfig.defaultFonts.monospace = [
      "DejaVu Sans Mono"
      "Noto Color Emoji"
    ];

    # Install some extra fonts.
    fonts.fonts = with pkgs; [
      jetbrains-mono
#      nerdfonts
    ];

    services.picom = {
      enable = true;
      vSync = "opengl";
    };

    nixpkgs.config.allowUnfree = true;
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      feh
      pulsemixer
      firefox
      mpv
      kitty
      timeular
      bitwarden
      discord-canary
    ];

    nixpkgs.overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs (oldAttrs: rec {
          src = sources.dwm;
        });
      }
      )
];

    # enable cups
    services.printing.enable = true;

    hardware.pulseaudio.enable = true;
    # # Set up Pipewire for audio
    # services.pipewire.enable = true;
    # services.pipewire.alsa.enable = true;
    # services.pipewire.pulse.enable = true;
    # services.pipewire.jack.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.displayManager.defaultSession = "none+dwm";
    services.xserver.windowManager.dwm.enable = true;

    # Don't have xterm as a session manager.
    services.xserver.desktopManager.xterm.enable = false;

    # Keyboard layout.
    services.xserver.layout = "de";
    services.xserver.xkbOptions = "caps:swapescape";

    # Enable networkmanager.
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # 8000 is for random web sharing things.
    networking.firewall.allowedTCPPorts = [ 8000 ];

    # Define extra groups for user.
    ragon.user.extraGroups = [ "networkmanager" "dialout" "audio" "input" ];
  };
}

