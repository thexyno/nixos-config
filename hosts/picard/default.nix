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

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";


  networking.useDHCP = true; # needed for initramfs
  # networking.interfaces.eno1.useDHCP = true;
  networking.hostId = "7c25236a";

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  ragon = {
    cli.enable = true;
    user.enable = true;
    persist.enable = true;

    services = {
      ssh.enable = true;
      nextcloud.enable = true;
      bitwarden.enable = true;
      gitlab.enable = true; # TODO gitlab-runner
      synapse.enable = true;
      nginx.enable = true;
      nginx.domain = "hochkamp.eu";
    };

  };


}
