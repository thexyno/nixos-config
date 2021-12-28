{ config, inputs, options, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.gui;
  username = config.ragon.user.username;
  system = pkgs.system;
in
{
  options.ragon.gui.enable = lib.mkEnableOption "Enables ragons Gui stuff";
  options.ragon.gui.laptop = mkBoolOpt false;
  options.ragon.gui.autostart = lib.mkOption {
    type = lib.types.listOf (lib.types.listOf lib.types.str);
    default = [
      [ "autorandr" "-c" ]
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
    services.yubikey-agent.enable = true;
    ragon.gui.dwm.enable = mkDefault true;
    services.pcscd.enable = true;
    # Set up default fonts
    fonts.enableDefaultFonts = true;
    fonts.enableGhostscriptFonts = true;
    # Needed for themes and backgrounds
    environment.pathsToLink = [
      "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
    ];


    # Configure fontconfig to actually use more of Noto Color Emoji in
    # alacritty.
    fonts.fontconfig.defaultFonts.monospace = [
      "JetBrainsMono Nerd Font"
      "Noto Color Emoji"
    ];

    fonts.fontconfig.defaultFonts.sansSerif = [
      "Source Sans Pro"
      "JetBrainsMono Nerd Font" # nerd font so their glyphs work
    ];

    fonts.fontconfig.defaultFonts.serif = [
      "Source Serif Pro"
      "JetBrainsMono Nerd Font" # nerd font so their glyphs work
    ];

    # Install some extra fonts.
    fonts.fonts = with pkgs; [
      jetbrains-mono
      cantarell-fonts
      dejavu_fonts
      source-code-pro # Default monospace font gnome
      source-sans-pro
      source-serif-pro
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    qt5.style = "adwaita-dark";

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    ragon.services.mullvad.enable = true;
    environment.systemPackages =
      with pkgs; [
        orca
        glib # for gsettings
        gnome-menus
        gtk3.out # for gtk-launch
        hicolor-icon-theme
        shared-mime-info # for update-mime-database
        libreoffice-fresh
        arc-icon-theme
        feh
        pulsemixer
        gimp
        firefox
        thunderbird
        st-ragon
        sxiv
        yubikey-agent
        yubikey-manager
        yubikey-manager-qt
        yubikey-personalization
        yubikey-personalization-gui
        gnome.eog
        gnome.epiphany
        gnome.gnome-calculator
        gnome.gnome-calendar
        gnome.gnome-characters
        gnome.gnome-clocks
        gnome.gnome-contacts
        gnome.gnome-font-viewer
        gnome.gnome-logs
        gnome.nautilus
        gnome.simple-scan
      ] ++ (optionals (system == "x86_64-linux") [
        signal-desktop
        bitwarden
        obs-studio
        unstable.discord
        spotify
        unstable.timeular
      ]);
    # Let nautilus find extensions
    # TODO: Create nautilus-with-extensions package
    environment.sessionVariables.NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-3.0";

    programs.evince.enable = true;
    programs.file-roller.enable = true;
    programs.gnome-disks.enable = true;
    # security.wrappers.cnping = {
    #   source = "${pkgs.my.cnping}/bin/cnping";
    #   owner = "nobody";
    #   group = "nogroup";
    #   capabilities = "cap_net_raw+ep";
    # };

    ragon.user.persistent.extraFiles = [
      ".cache/rofi3.druncache" # rofi cache so the search priorities are not garbage
      ".cache/wofi-drun" # rofi cache so the search priorities are not garbage
    ];

    ragon.user.persistent.extraDirectories = [
      ".config/dconf"
      "Pictures"
      ".local/share/dolphin/view_properties/global"
      ".config/session"
      ".local/share/okular"
      ".local/share/konsole"
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

    services.gnome.sushi.enable = true;
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
    services.system-config-printer.enable = true;
    services.avahi.enable = true;
    # scanning
    hardware.sane.enable = true;
    hardware.sane.extraBackends = [ pkgs.sane-airscan ];

    # Important to resolve .local domains of printers, otherwise you get an error
    # like  "Impossible to connect to XXX.local: Name or service not known"
    services.avahi.nssmdns = true;


    # hardware.pulseaudio.enable = true;
    # # Set up Pipewire for audio
    hardware.pulseaudio.enable = mkForce false;
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.jack.enable = true;


    # Don't have xterm as a session manager.
    services.xserver.desktopManager.xterm.enable = false;

    # Keyboard layout.
    services.xserver.layout = "eu";
    hardware.keyboard.zsa.enable = true;

    # 8000 is for random web sharing things.
    networking.firewall.allowedTCPPorts = [ 8000 ];

    # Define extra groups for user.
    ragon.user.extraGroups = [ "networkmanager" "dialout" "audio" "input" "scanner" "lp" "video" "plugdev" ];
  };
}
