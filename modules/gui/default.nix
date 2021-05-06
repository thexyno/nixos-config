{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.gui;
  username = config.ragon.user.username;
in
{
  options.ragon.gui.enable = lib.mkEnableOption "Enables ragons Gui stuff";
  options.ragon.gui.laptop = lib.mkOption {
    type = lib.types.bool;
    default = false;

  };
  options.ragon.gui.autostart = lib.mkOption {
    type = lib.types.listOf (lib.types.listOf lib.types.str);
    default = [
      [ "nvidia-settings" "--assign" "CurrentMetaMode=CurrentMetaMode=DVI-I-1: nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, HDMI-0: 2560x1440 +1680+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-1: 2560x1440 +4240+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}; DVI-I-1: nvidia-auto-select +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 1280x1024 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 1280x1024_60 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 1280x960 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 1152x864 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 1024x768 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 1024x768_60 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 800x600 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 800x600_60 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 800x600_56 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 640x480 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: 640x480_60 +0+0, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: nvidia-auto-select +0+0 {viewportin=1440x900}, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: nvidia-auto-select +0+0 {viewportin=1366x768, viewportout=1680x944+0+53}, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: nvidia-auto-select +0+0 {viewportin=1280x800}, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: nvidia-auto-select +0+0 {viewportin=1280x720, viewportout=1680x945+0+52}, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0; DVI-I-1: nvidia-auto-select +0+0 {viewportout=1680x945+0+52}, HDMI-0: nvidia-auto-select +0+0, DP-1: nvidia-auto-select +1680+0" ]
      [ "sh" "-c" "cd /home/username/proj/pulse-launch; pipenv run python pulse_launch.py --term_cmd 'toggleSpeakers turn_off' --other_cmd 'toggleSpeakers turn_off' 'alsa_output.usb-BEHRINGER_UMC202HD_192k-00.analog-stereo' 'toggleSpeakers turn_on'" ]
    ];
  };
  options.ragon.gui.spcmd1cmd = lib.mkOption {
    type = lib.types.str;
    default = "bitwarden";
  };
  options.ragon.gui.spcmd1class = lib.mkOption {
    type = lib.types.str;
    default = "bitwarden";
  };
  options.ragon.gui.spcmd2cmd = lib.mkOption {
    type = lib.types.str;
    default = "timeular";
  };
  options.ragon.gui.spcmd2class = lib.mkOption {
    type = lib.types.str;
    default = "timeular";
  };
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
      nerdfonts
    ];


    nixpkgs.config.allowUnfree = true;
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    services.ratbagd.enable = true; # mx master control daemon
    environment.systemPackages = with pkgs; [
      piper # mx master control software
      libreoffice-fresh
      master.timeular
      cinnamon.nemo
      arc-icon-theme
      feh
      pulsemixer
      gimp
      firefox
      thunderbird
      mpv
      kitty
      timeular
      sxiv
      signal-desktop
      bitwarden
      discord
      spotify
      obs-studio
    ];

    services.mullvad-vpn.enable = true;

    ragon.user.persistent.extraFiles = [
      ".cache/rofi3.druncache" # rofi cache so the search priorities are not garbage
    ];

    ragon.user.persistent.extraDirectories = [
      ".config/discord"
      ".config/Bitwarden"
      ".config/libreoffice"
      ".config/Timeular"
      ".config/Signal"
      ".config/spotify"
      ".cache/spotify" # downloaded songs
      ".config/obs-studio"
      ".mozilla/"
      ".cache/mozilla" # firefox cache
      ".thunderbird/" # Because of cause this isn't in .mozilla
    ];

    # enable cups
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];
    services.avahi.enable = true;
    # scanning
    hardware.sane.enable = true;
    hardware.sane.extraBackends = [ pkgs.hplipWithPlugin pkgs.sane-airscan ];

    # Important to resolve .local domains of printers, otherwise you get an error
    # like  "Impossible to connect to XXX.local: Name or service not known"
    services.avahi.nssmdns = true;


    hardware.pulseaudio.enable = true;
    # # Set up Pipewire for audio
    # services.pipewire.enable = true;
    # services.pipewire.alsa.enable = true;
    # services.pipewire.pulse.enable = true;
    # services.pipewire.jack.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Don't have xterm as a session manager.
    services.xserver.desktopManager.xterm.enable = false;

    # Keyboard layout.
    services.xserver.layout = "de";
    services.xserver.xkbOptions = "caps:swapescape";

    # 8000 is for random web sharing things.
    networking.firewall.allowedTCPPorts = [ 8000 ];

    # Enable networkmanager.
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # Define extra groups for user.
    ragon.user.extraGroups = [ "networkmanager" "dialout" "audio" "input" "scanner" "lp" ];
  };
}
