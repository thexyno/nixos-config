# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  services.syncthing.enable = true;
  services.syncthing.user = "ragon";

  security.sudo.wheelNeedsPassword = false;
  networking.useDHCP = true;
  networking.bridges."br0".interfaces = [ ];
  networking.hostId = "7b4c2932";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
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

  # services.restic.backups."ds9" = {
  #   rcloneConfigFile = "/run/secrets/ds9rcloneConfig";
  #   passwordFile = "/run/secrets/ds9resticPassword";
  #   pruneOpts = [
  #     "--keep-daily 7"
  #     "--keep-weekly 5"
  #     "--keep-monthly 12"
  #     "--keep-yearly 75"
  #   ];
  #   initialize = true;
  #   repository = "rclone:ds9:/ds9";
  #   paths = [
  #     "/data"
  #     "/persistent/var/lib"
  #   ];

  # };

  ragon.agenix.secrets."ds9rcloneConfig" = { };
  ragon.agenix.secrets."ds9resticPassword" = { };


  # Enable Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.extraServiceFiles.smb = ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
        <type>_smb._tcp</type>
        <port>445</port>
        <host-name>ds9.hailsatan.eu</host-name>
      </service>
      <service>
        <type>_device-info._tcp</type>
        <port>0</port>
        <txt-record>model=MacPro7,1@ECOLOR=226,226,224</txt-record>
      </service>
      <service>
        <type>_adisk._tcp</type>
        <txt-record>sys=waMa=0,adVF=0x100</txt-record>
        <txt-record>dk0=adVN=TimeMachine,adVF=0x82</txt-record>
        <host-name>ds9.hailsatan.eu</host-name>
      </service>
    </service-group>
  '';
  # Webhook service to trigger scanning the ADF from HomeAssistant
  systemd.services.scanhook = {
    description = "webhook go server to trigger scanning";
    documentation = [ "https://github.com/adnanh/webhook" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ bash ];
    serviceConfig = {
      TemporaryFileSystem = "/:ro";
      BindReadOnlyPaths = [
        "/nix/store"
        "-/etc/resolv.conf"
        "-/etc/nsswitch.conf"
        "-/etc/hosts"
        "-/etc/localtime"
      ];
      BindPaths = [
        "/data/applications/paperless-consumption"
      ];
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProcSubset = "pid";
      ProtectHome = true;
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      DynamicUser = true;
      ExecStart =
        let
          scanScript = pkgs.writeScript "plscan.sh" ''
            #!/usr/bin/env bash
            export PATH=${lib.makeBinPath [ pkgs.strace pkgs.gnugrep pkgs.coreutils pkgs.sane-backends pkgs.sane-airscan pkgs.imagemagick ]}
            export LD_LIBRARY_PATH=${config.environment.sessionVariables.LD_LIBRARY_PATH} # Adds SANE Libraries to the ld library path of this script
            set -x
            date="''$(date --iso-8601=seconds)"
            filename="Scan ''$date.pdf"
            tmpdir="''$(mktemp -d)"
            pushd "''$tmpdir"
            scanimage --batch=out%d.jpg --format=jpeg --mode Gray -d "airscan:e0:Canon MB5100 series" --source "ADF Duplex" --resolution 300
            for i in $(ls out*.jpg | grep 'out.*[24680]\.jpg'); do convert $i -rotate 180 $i; done # rotate even stuff
            convert out*.jpg /data/applications/paperless-consumption/"''$filename"
            chmod 666 /data/applications/paperless-consumption/"''$filename"
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
        "${pkgs.webhook}/bin/webhook -hooks ${hooksFile} -verbose";
    };
  };
  networking.firewall.allowedTCPPorts = [ 9000 ];

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  services.samba.extraConfig = ''
    min protocol = SMB3
    vfs objects = acl_xattr catia fruit streams_xattr
    fruit:nfs_aces = no
    inherit permissions = yes
    fruit:posix_rename = yes 
    fruit:model = MacPro7,1@ECOLOR=226,226,224
    fruit:veto_appledouble = no
    fruit:wipe_intentionally_left_blank_rfork = yes 
    fruit:delete_empty_adfiles = yes 
    fruit:metadata = stream
  '';

  ragon = {
    cli.enable = true;
    user.enable = true;
    home-manager.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/var/lib/syncthing" ];

    services = {
      samba.enable = true;
      samba.shares = {
        TimeMachine = {
          path = "/backups/DaedalusTimeMachine";
          comment = "DaedalusTimeMachine";
          "write list" = "@wheel";
          "fruit:time machine" = "yes";
          "fruit:time machine max size" = "2050G";
          "vfs objects" = "acl_xattr fruit streams_xattr";
          "inherit acls" = "yes";
        };
        data = {
          path = "/data";
          comment = "some data for the people";
          "write list" = "@wheel";
        };
      };
      docker.enable = true;
      ssh.enable = true;
      nginx.enable = true;
      jellyfin.enable = true;
      tailscale.enable = true;
      grafana.enable = true;
      libvirt.enable = true;
      paperless.enable = true;
      unifi.enable = true;
    };

  };
}
