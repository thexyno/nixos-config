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

  security.sudo.wheelNeedsPassword = false;
  networking.useDHCP = true;
  networking.bridges."br0".interfaces = [];
  networking.hostId = "7b4c2932";
  boot.initrd.network = {
    enable = true;
    postCommands = ''
      zpool import rpool
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [
        "/persistent/etc/nixos/secrets/initrd/ssh_host_rsa_key"
        "/persistent/etc/nixos/secrets/initrd/ssh_host_ed25519_key"
      ];
      authorizedKeys = pkgs.pubkeys.ragon.computers;

    };

  };

  services.restic.backups."ds9" = {
    rcloneConfigFile = "/run/secrets/ds9rcloneConfig";
    passwordFile = "/run/secrets/ds9resticPassword";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
    initialize = true;
    repository = "rclone:ds9:/ds9";
    paths = [
      "/data"
      "/persistent/var/lib"
    ];

  };

  ragon.agenix.secrets."ds9rcloneConfig" = {};
  ragon.agenix.secrets."ds9resticPassword" = {};


  # Immutable users due to tmpfs
  users.mutableUsers = false;

  ragon = {
    cli.enable = true;
    user.enable = true;
    home-manager.enable = false;
    persist.enable = true;

    services = {
      docker.enable = true;
      ssh.enable = true;
      nfs.enable = true;
      nginx.enable = true;
      jellyfin.enable = true;
      libvirt.enable = true;
      paperless.enable = true;
    };

  };


}
