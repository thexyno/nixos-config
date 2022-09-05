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
  environment.systemPackages = [ pkgs.nfs-utils pkgs.virt-manager pkgs.firefox ];

  nix.settings.extra-platforms = [ "x86_64-linux" ];
  nix.settings.extra-sandbox-paths = [ "/tmp/rosetta" "/run/binfmt" ];
  boot.binfmt.registrations."rosetta" = {
    interpreter = "/tmp/rosetta/rosetta";
    fixBinary = true;
    wrapInterpreterInShell = false;
    matchCredentials = true;
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  };

  services.qemuGuest.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  services.spice-vdagentd.enable = true;
  programs.gnome-terminal.enable = true;
  services.gvfs.enable = true;


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
