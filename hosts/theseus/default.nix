{ config, inputs, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./kmonad.nix

      ../../nixos-modules/networking/tailscale.nix
      ../../nixos-modules/services/ssh.nix
      ../../nixos-modules/system/agenix.nix
      ../../nixos-modules/system/persist.nix
      ../../nixos-modules/user
      # ./gnome.nix
    ];

  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [ pkgs.cifs-utils ];
  nix.extraOptions = # devenv
    ''
      trusted-users = root ragon
    '';



  users.extraGroups.plugdev = { };
  services.udev.packages = [ pkgs.openocd pkgs.probe-rs-tools ];


  hardware.keyboard.zsa.enable = true;
  services.tailscale.useRoutingFeatures = lib.mkForce "client";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config = {
      river = {
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
        default = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      };


    };
  };
  ragon.agenix.secrets.smbSecrets = { };
  # fileSystems."/data" = {
  #   device = "//ds9.kangaroo-galaxy.ts.net/data";
  #   fsType = "cifs";
  #   options = let
  #     automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";

  #     in ["${automount_opts},credentials=${config.age.secrets.smbSecrets.path},uid=1000,gid=100"];
  # };
  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/4cd8dbb3-8eea-48ff-87b1-92945be291ac";
  programs.fuse.userAllowOther = true;
  programs.sway.enable = true;
  programs.nix-ld.enable = true;
  programs.gamescope.enable = true;
  programs.wireshark.enable = true;
  services.gnome.sushi.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;
  services.gvfs.enable = true;
  services.logind.extraConfig = ''
    # supspend on pw button press
    HandlePowerKey=suspend
  '';
  programs.kdeconnect.enable = true;
  services.power-profiles-daemon.enable = true;
  programs.sway.extraSessionCommands = ''
    export NIXOS_OZONE_WL=1
  '';
  # start bt
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # end bt
  # start printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };
  services.printing.enable = true;
  services.printing.logLevel = "debug";




  # end printing
  programs.light.enable = true;
  # networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.useDHCP = lib.mkDefault true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.core-utilities.enable = true;
  services.displayManager.defaultSession = "river";
  programs.river.enable = true;
  services.upower.enable = true;
  users.users.ragon.extraGroups = [ "networkmanager" "video" "netdev" "plugdev" "dialout" "tape" "uucp" "wireshark" ];
  fonts.packages = with pkgs; [
    nerdfonts
    cantarell-fonts
    dejavu_fonts
    source-code-pro # Default monospace font in 3.32
    source-sans
    b612

  ];
  services.pipewire = {
    enable = true;
    raopOpenFirewall = true; # airplay
    pulse.enable = true;
    extraConfig.pipewire = {
      "9-clock-allow-higher" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [ "44100" "48000" "96000" "192000" ];
        };
      };
      "10-raop-discover" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
            args = { };
          }
        ];
      };
    };
  };
  services.fwupd.enable = true;

  programs.ssh.startAgent = true;

  programs.evolution.enable = true;
  services.gnome.evolution-data-server.enable = true;
  services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
    imports = [
      ../../hm-modules/helix
      ../../hm-modules/nushell
      ../../hm-modules/zellij
      ../../hm-modules/cli.nix
      ./swaycfg.nix
      ./work.nix
      ./river.nix
      ../../hm-modules/files.nix
      inputs.wired.homeManagerModules.default
    ];
    ragon.helix.enable = true;
    ragon.nushell.enable = true;
    ragon.nushell.isNixOS = true;
    ragon.zellij.enable = true;
    services.gnome-keyring.enable = true;
    home.file.".config/wezterm/wezterm.lua".text = ''
      local wezterm = require 'wezterm'

      

      -- This will hold the configuration.
      local config = wezterm.config_builder()

      config.default_prog = { 'nu' }
      config.hide_tab_bar_if_only_one_tab = true
      config.max_fps = 144
      config.font = wezterm.font 'Source Code Pro'

      -- This is where you actually apply your config choices

      -- For example, changing the color scheme:
      config.color_scheme = 'Gruvbox Dark (Gogh)'

      -- and finally, return the configuration to wezterm
      return config
    '';
    services.syncthing.enable = true;
    services.syncthing.tray.enable = true;
    services.syncthing.tray.command = "syncthingtray --wait";
    programs.firefox.nativeMessagingHosts = [ pkgs.unstable.firefoxpwa pkgs.unstable.keepassxc ];
    programs.firefox.enable = true;


    home.packages = with pkgs; [
      # inputs.wezterm.packages.${pkgs.system}.default
      element-desktop # this is not a place of honor
      discord # shitcord
      unstable.signal-desktop
      unstable.firefoxpwa
    mosh
      unstable.plexamp
      # firefox
      obsidian
      thunderbird
      # unstable.orca-slicer
      diebahn
      vlc
      dolphin
      # unstable.kicad
      unstable.devenv
      lutris
      libsecret
      mixxx
      unstable.harsh
      libreoffice-qt6-fresh
      inkscape
      easyeffects
      dune3d
      ptyxis
      appimage-run
      unstable.keepassxc
      # unstable.zenbrowser
      inputs.zen-browser.packages."${pkgs.system}".default

      # filezilla

      broot
    ];
    home.file.".zshrc".text = lib.mkForce ''
      # we're using nushell as our interactive shell
      # so if zsh gets spawned by our terminal emulator, exec nu
      cat /proc/$PPID/cmdline | grep -q alacritty && exec nu
    '';
    services.kdeconnect = {
      enable = true;
      indicator = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };



    # home.persistence."/persistent/home/ragon" =
    #   {
    #     directories = [
    #       ".mozilla"
    #       ".cache"
    #       ".ssh"
    #       "docs"
    #       "Images"
    #       "Downloads"
    #       "Music"
    #       "Pictures"
    #       "Documents"
    #       "Videos"
    #       "VirtualBox VMs"
    #       ".gnupg"
    #       ".ssh"
    #       ".local/share/keyrings"
    #       ".local/share/direnv"
    #       ".local/share/Steam"
    #     ];
    #     allowOther = true;
    #   };
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "JetBrainsMono NerdFont";
        colors = {
          primary = {
            # hard contrast
            background = "#1d2021";
            # normal background = "#282828";
            # soft contrast background = = "#32302f"
            foreground = "#ebdbb2";
          };
          normal = {
            black = "#282828";
            red = "#cc241d";
            green = "#98971a";
            yellow = "#d79921";
            blue = "#458588";
            magenta = "#b16286";
            cyan = "#689d6a";
            white = "#a89984";
          };
          bright = {
            black = "#928374";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#83a598";
            magenta = "#d3869b";
            cyan = "#8ec07c";
            white = "#ebdbb2";
          };
        };
      };
    };
    programs.borgmatic = {
      enable = true;
      backups.system =
        let
          notify = "${pkgs.libnotify}/bin/notify-send";
        in
        {
          location.sourceDirectories = [ "/persistent" ];
          location.repositories = [{ path = "ssh://ragon@ds9//backups/theseus"; }];
          location.extraConfig.exclude_if_present = [ ".nobackup" ];
          storage.encryptionPasscommand = "${pkgs.libsecret}/bin/secret-tool lookup borg-repository system";
          location.extraConfig.before_backup = [ "${notify} -u low -a borgmatic borgmatic \"starting backup\" -t 10000" ];
          location.extraConfig.after_backup = [ "${notify} -u low -a borgmatic borgmatic \"finished backup\" -t 10000" ];
          location.extraConfig.on_error = [ "${notify} -u critical -a borgmatic borgmatic \"backup failed\"" ];
          # location.extraConfig.ssh_command = "ssh -i /home/ragon/.ssh/id_ed25519";
          location.extraConfig.one_file_system = true;
          retention = {
            keepHourly = 24;
            keepDaily = 7;
            keepWeekly = 4;
            keepMonthly = 12;
            keepYearly = 2;
          };
        };
    };
    services.borgmatic.enable = true;
  };

  ragon = {
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [
      "/var/lib/bluetooth"
      "/var/lib/flatpak"
      "/var/lib/iwd"
      "/var/log" #lol
    ];
    services = {
      ssh.enable = true;
      tailscale.enable = true;
    };

  };
}
