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

  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  networking.hostId = "7b45236b";

  # Immutable users due to tmpfs
  users.mutableUsers = false;


  ragon.cli.enable = true;
  ragon.cli.pandoc.enable = true;
  ragon.user.enable = true;
  ragon.home-manager.enable = true;
  ragon.gui.enable = true;
  ragon.develop.enable = true;
  ragon.persist.enable = true;
  ragon.services.docker.enable = true;
  ragon.services.libvirt.enable = true;
  ragon.services.ssh.enable = true;

  services.k3s.enable = true;



  ragon.user.persistent.extraDirectories = [
    ".cache" # hopefully helps with ram
  ];
  environment.systemPackages = with pkgs; [
    virt-manager
    k3s
  ];


}
