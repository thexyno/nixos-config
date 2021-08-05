# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, lib, ... }:

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
  networking.bridges."br0".interfaces = [ ];
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

  ragon.agenix.secrets."ds9rcloneConfig" = { };
  ragon.agenix.secrets."ds9resticPassword" = { };


  # Enable Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # Webhook service to trigger scanning the ADF from HomeAssistant
  systemd.services.scanhook = {
    description = "webhook go server to trigger scanning";
    documentation = "https://github.com/adnanh/webhook";
    wantedBy = [ "ulti-user.target" ];
    path = with pkgs; [ ];
    serviceConfig = {
      DynamicUser = true;
      PrivateTmp = true;
      ExecStart =
        let
          scanScript = pkgs.writeScript "plscan.sh" ''
            #!/usr/bin/env bash
            export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.sane-backends pkgs.imagemagick ]}
            set -x
            date="''$(date --iso-8601=seconds)"
            filename="Scan ''$date.pdf"
            tmpdir="''$(mktemp -d)"
            pushd "''$tmpdir"
            scanimage --batch=out%d.jpg --format=jpeg --mode Gray -d "airscan:e0:Canon MB5100 series" --source "ADF Duplex" --resolution 300
            convert out*.jpg /data/applications/paperless-consumption/"$filename"
            popd
            rm -r "''$tmpdir"
          '';
          hooksFile = pkgs.writeText "webhook.json" (builtins.toJSON [
            {
              id = "scan-webhook";
              execute-command = "${scanScript}";

            }
          ]);
        in
        "${pkgs.webhook}/bin/webhook -hooks ${hooksFile}";
    };
  };


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
