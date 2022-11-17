# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  security.polkit.enable = true; # needed for libvirtd
  services.glusterfs.enable = true;
  environment.systemPackages = [ pkgs.python3 ];
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;

  };


  # Immutable users due to tmpfs
  users.mutableUsers = false;


  programs.mosh.enable = true;
  ragon = {
    services = {
      ssh.enable = true;
    };
  };

}
