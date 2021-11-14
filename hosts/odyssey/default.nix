# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, inputs, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  networking.hostId = "7b45237b";

  # Immutable users due to tmpfs
  users.mutableUsers = false;


  ragon.cli.enable = true;
  #ragon.cli.pandoc.enable = true;
  ragon.user.enable = true;
  #ragon.home-manager.enable = true;
  #ragon.gui.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  ragon.gui.dwm.enable = lib.mkForce false;
  services.xserver.enable = true;
  services.xserver.displayManager.autoLogin.user = "ragon";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;

  #ragon.gui.river.enable = true;
  #ragon.gui.gaming.enable = true;
  ragon.persist.enable = true;
  ragon.services.ssh.enable = true;

  ragon.user.persistent.extraDirectories = [
    ".cache" # hopefully helps with ram
    ".config" # to lazy to figure out where kde stores its stuff
    ".local" # to lazy to figure out where kde stores its stuff
  ];
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.zeroconf.publish.enable = true;
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" "10.0.0.0/8" ];
  ragon.user.extraGroups = [ "audio" "networkmanager" "dialout" "audio" "input" "scanner" "lp" "video" ];
  environment.systemPackages =
    with pkgs; [
      firefox
      obs-studio
      unstable.discord
      spotify
    ];


  users.users.nzbr = {
    isNormalUser = true;
    extraGroups = [ "audio" ];
  };
  ragon.persist.extraDirectories = [ "/home" ];
  hardware.pulseaudio.systemWide = true;
  xdg.autostart.enable = true;

  security.sudo.extraRules = [
    { users = [ "ragon" ]; runAs = "nzbr"; commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }]; }
  ];


}
