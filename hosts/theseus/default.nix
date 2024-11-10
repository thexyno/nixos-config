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
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/4cd8dbb3-8eea-48ff-87b1-92945be291ac";
  programs.fuse.userAllowOther = true;
  programs.sway.enable = true;
  programs.nix-ld.enable = true;
  services.power-profiles-daemon.enable = true;
  programs.sway.extraSessionCommands = ''
    export NIXOS_OZONE_WL=1
  '';
  xdg.portal = {
    wlr.enable = true;
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  # start bt
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # end bt
  programs.light.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.defaultSession = "river";
  services.upower.enable = true;
  users.users.ragon.extraGroups = [ "networkmanager" "video" ];
  programs.kde-pim = { enable = true; kmail = true; kontact = true; merkuro = true; };
  environment.systemPackages = [
    pkgs.qt6.qtwayland
  ];
  fonts.packages = [
    pkgs.nerdfonts
  ];
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.fwupd.enable = true;
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
      ./kanshi.nix
      ../../hm-modules/files.nix
    ];
    ragon.helix.enable = true;
    ragon.nushell.enable = true;
    ragon.zellij.enable = true;
    services.gnome-keyring.enable = true;
    home.file.".config/wezterm/wezterm.lua".text = ''
      local wezterm = require 'wezterm'

      -- This will hold the configuration.
      local config = wezterm.config_builder()

      config.default_prog = { 'zellij', 'attach', '-c' }
      config.hide_tab_bar_if_only_one_tab = true
      config.max_fps = 144

      -- This is where you actually apply your config choices

      -- For example, changing the color scheme:
      config.color_scheme = 'Gruvbox Dark (Gogh)'

      -- and finally, return the configuration to wezterm
      return config
    '';

    home.packages = with pkgs; [
      wezterm
      element-desktop # this is not a place of honor
      unstable.signal-desktop
      plexamp
      firefox
      gnome.seahorse
      obsidian
      thunderbird
    ];



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
  };

  ragon = {
    user.enable = true;
    persist.enable = true;
    services = {
      ssh.enable = true;
      tailscale.enable = true;
    };

  };
}
