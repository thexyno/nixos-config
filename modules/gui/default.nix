{ config, inputs, options, lib, pkgs, ... }:
with lib;
with lib.my;
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
      [ ]
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


    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    documentation.info.enable = false; # https://github.com/NixOS/nixpkgs/issues/124215#issuecomment-846762260
    environment.systemPackages =
      with pkgs; [
        libreoffice-fresh
        cinnamon.nemo
        arc-icon-theme
        feh
        pulsemixer
        gimp
        firefox
        thunderbird
        mpv
        kitty
        sxiv
        signal-desktop
        wireguard
        bitwarden
        obs-studio
        unstable.discord
        spotify
        unstable.timeular
      ];

    security.wrappers.cnping = {
      source = "${pkgs.my.cnping}/bin/cnping";
      owner = "nobody";
      group = "nogroup";
      capabilities = "cap_net_raw+ep";
    };

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

    services.gnome.glib-networking.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.xserver.updateDbusEnvironment = true;

    # Enable colord server
    services.colord.enable = true;

    # Enable dconf
    programs.dconf.enable = true;

    # Enable org.a11y.Bus
    services.gnome.at-spi2-core.enable = true;


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

    # Define extra groups for user.
    ragon.user.extraGroups = [ "networkmanager" "dialout" "audio" "input" "scanner" "lp" "video" ];
  };
}
