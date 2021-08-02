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


  networking.interfaces."ens3" = {
    ipv4 = {
      addresses = [
        {
          address = "202.61.248.252";
          prefixLength = 22;
        }
      ];
    };
    ipv6 = {
      addresses = [
        {
          address = "2a03:4000:54:a98::1";
          prefixLength = 64;
        }
      ];
    };


  };
  # networking.interfaces.eno1.useDHCP = true;
  networking.hostId = "7c21236a";

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  ragon = {
    cli.enable = true;
    user.enable = true;
    persist.enable = true;

    services = {
      ssh.enable = true;
      bitwarden.enable = true;
      # gitlab.enable = true; # TODO gitlab-runner
      synapse.enable = true;
      nginx.enable = true;
      nginx.domain = "ragon.xyz";
    };

  };


}
