# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

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
    ipv6 = {
      addresses = [
        {
          address = "2a03:4000:54:a98::1";
          prefixLength = 64;
        }
      ];
    };
  };
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s3"; };
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  # networking.interfaces.eno1.useDHCP = true;
  networking.hostId = "7c21236a";

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  services.postgresql.package = pkgs.postgresql_13;

  ragon = {
    cli.enable = true;
    user.enable = true;
    home-manager.enable = true;
    persist.enable = true;

    services = {
      ssh.enable = true;
      bitwarden.enable = true;
      gitlab.enable = true; # TODO gitlab-runner
      synapse.enable = true;
      jitsi.enable = true;
      hedgedoc.enable = true;
      ts3.enable = true;
      nginx.enable = true;
      nginx.domain = "ragon.xyz";
    };

  };

}
