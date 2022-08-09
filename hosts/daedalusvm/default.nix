# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, lib, ... }:
let
  pubkeys = import ../../data/pubkeys.nix;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Immutable users due to tmpfs
  users.mutableUsers = false;
  services.openssh.forwardX11 = true;
  services.rpcbind.enable = true;
  boot.supportedFilesystems = [ "nfs" "nfs4" ];
  environment.systemPackages = [ pkgs.nfs-utils ];

  ragon = {
    cli.enable = true;
    user.enable = true;
    system.security.enable = false;

    services = {
      docker.enable = true;
      ssh.enable = true;
    };
  };
}
