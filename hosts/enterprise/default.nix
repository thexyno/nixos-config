# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  # grubbi grub grub
  boot.loader.grub = {
    efiSupport = true;
    useOSProber = true; # needed for windoof
    device = "nodev";
  };

  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.hostId = "7b45236a";

  # Immutable users due to tmpfs
  users.mutableUsers = false;


  ragon.cli.enable = true;
  ragon.cli.pandoc.enable = true;
  ragon.cli.emacs.enable = true;
  ragon.gui.gaming.enable = true;
  ragon.user.enable = true;
  ragon.home-manager.enable = true;
  ragon.gui.enable = true;
  ragon.develop.enable = true;
  ragon.persist.enable = true;
  ragon.services.gamingvmhost.enable = true;
  ragon.services.docker.enable = true;
  ragon.services.ssh.enable = true;
  ragon.hardware.bluetooth.enable = true;
  ragon.agenix.secrets.pulseLaunch = { owner = "ragon"; };
  systemd.user.services."pulselaunch" = {
    path = with pkgs; [ curl my.pulse_launch ];
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      source /run/secrets/pulseLaunch
      pulse_launch alsa_output.usb-Focusrite_Scarlett_Solo_USB_Y74EVUD137B9F2-00.analog-stereo "$ON" --other_cmd "$OFF" --term_cmd "$OFF"
    '';
  };
  hardware.pulseaudio.extraConfig = ''
    load-module module-remap-source master=alsa_input.usb-Focusrite_Scarlett_Solo_USB_Y74EVUD137B9F2-00.analog-stereo source_name=Mic-Mono master_channel_map=left channel_map=mono
    set-default-source Mic-Mono
  '';



}
