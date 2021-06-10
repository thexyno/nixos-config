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
  boot.loader.systemd-boot.enable = true;

  networking =
    let
      primaryInterface = "enp3s0";
    in
    {
      useDHCP = false;
      domain = "hailsatan.eu";
      vlans = {
        lan = {
          id = 4;
          interface = "${primaryInterface}";
        };
        iot = { id = 2; interface = "${primaryInterface}"; };
      };
      interfaces.lan.ipv4.addresses = [{
        address = "10.0.0.2";
        prefixLength = 16;
      }];
      interfaces.iot.ipv4.addresses = [{
        address = "10.1.0.2";
        prefixLength = 16;
      }];
      hostId = "7b45236c";
      defaultGateway = "10.0.0.1";
      nameservers = [ "10.0.0.1" "1.1.1.1" ];
    };

    boot.initrd.network = {
      enable = true;
      postCommands = ''
       zpool import pool
       echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [
          "/etc/nixos/secrets/initrd/ssh_host_rsa_key"
          "/etc/nixos/secrets/initrd/ssh_host_ed25519_key"
        ];
        authorizedKeys = pkgs.pubkeys.ragon.computers;

      };

    };
  

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  ragon = {
    cli.enable = true;
    user.enable = true;
    home-manager.enable = true;
    persist.enable = true;

    services = {
      docker.enable = true;
      ssh.enable = true;
      nfs.enable = true;
      nginx.enable = true;
      jellyfin.enable = true;
      signal.enable = true;
      home-assistant.enable = true;
      ddns.enable = true;
    };

  };


}
