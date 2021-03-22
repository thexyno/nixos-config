{ config, lib, pkgs, ... }:
let
  sources = import ../nix/sources.nix;
  cfg = config.ragon.gui;
  username = config.ragon.user.username;
in
{
  options.ragon.gui.enable = lib.mkEnableOption "Enables ragons Gui stuff";
  options.ragon.gui.autostart = lib.mkOption {
    type = lib.types.listOf lib.types.listOf lib.types.str;
    default = [
      [ "nvidia-settings" "--assign" "CurrentMetaMode=DPY-1: nvidia-auto-select @1680x1050 +0+0 {ForceCompositionPipeline=On ViewPortIn=1680x1050 ViewPortOut=1680x1050+0+0} DPY-2: nvidia-auto-select @2560x1440 +1680+0 {ForceCompositionPipeline=On ViewPortIn=2560x1440 ViewPortOut=2560x1440+0+0} DPY-5: nvidia-auto-select @2560x1440 +4240+0 {ForceCompositionPipeline=On ViewPortIn=2560x1440 ViewPortOut=2560x1440+0+0}" ]
      [ "sh" "-c" "cd /home/${username}/proj/pulse-launch; pipenv run python pulse_launch.py --term_cmd 'toggleSpeakers turn_off' --other_cmd 'toggleSpeakers turn_off' 'alsa_output.usb-BEHRINGER_UMC202HD_192k-00.analog-stereo' 'toggleSpeakers turn_on'" ]
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
  imports = [
    ./gui/default.nix
  ];
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


    nixpkgs.config.allowUnfree = true;
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      feh
      pulsemixer
      firefox
      thunderbird
      mpv
      kitty
      timeular
      sxiv
      signal-desktop
      bitwarden
      discord-canary
      obs-studio
#      obs-v4l2sink now in obs-studio
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

    # Don't have xterm as a session manager.
    services.xserver.desktopManager.xterm.enable = false;

    # Keyboard layout.
    services.xserver.layout = "de";
    services.xserver.xkbOptions = "caps:swapescape";

    # 8000 is for random web sharing things.
    networking.firewall.allowedTCPPorts = [ 8000 ];

    # Define extra groups for user.
    ragon.user.extraGroups = [ "networkmanager" "dialout" "audio" "input" ];
  };
}

