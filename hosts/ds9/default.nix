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

  # power save stuffzies
  services.udev.path = [ pkgs.hdparm ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 60 -B 100 /dev/%k"
  '';

  services.syncthing.enable = true;
  services.syncthing.user = "ragon";

  ragon.agenix.secrets."ds9OffsiteBackupSSH" = { owner = config.services.syncoid.user; };
  ragon.agenix.secrets."ds9SyncoidHealthCheckUrl" = { owner = config.services.syncoid.user; mode = "444"; };
  ragon.agenix.secrets."gatebridgeHostKeys" = { owner = config.services.syncoid.user; };
  ragon.agenix.secrets."borgmaticEncryptionKey" = { };
  # services.syncoid =
  #   let
  #     datasets = {
  #       backups = "rpool/content/local/backups";
  #       data = "rpool/content/safe/data";
  #       ds9persist2 = "spool/safe/persist";
  #       hassosvm2 = "spool/safe/vms/hassos";
  #     };
  #   in

  #   lib.mkMerge (
  #     [{
  #       localSourceAllow = [
  #         "hold"
  #         "send"
  #         "snapshot"
  #         "destroy"
  #         "mount"
  #       ];
  #       enable = true;
  #       interval = "*-*-* 2:15:00";
  #       commonArgs = [ "--sshoption" "GlobalKnownHostsFile=${config.age.secrets.gatebridgeHostKeys.path}" ];
  #       sshKey = lib.mkForce "${config.age.secrets.ds9OffsiteBackupSSH.path}";
  #     }] ++
  #     (builtins.attrValues
  #       (builtins.mapAttrs (n: v: { commands.${n} = { target = "root@gatebridge:backup/${n}"; source = v; sendOptions = "w"; }; }) (datasets))
  #     )
  #   );
  # systemd.services."syncoid-ds9persist2" = {
  #   # ExecStartPost commands are only run if the ExecStart command succeeded
  #   # serviceConfig.ExecStartPost = pkgs.writeShellScript "backupSuccessful" ''
  #   #   ${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})
  #   # '';
  #   unitConfig.OnFailure = "backupFailure.service";
  # };

  # systemd.services.backupFailure = {
  #   enable = true;
  #   script = "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})/fail";
  # };

  services.borgmatic = {
    enable = true;
    configurations."ds9-offsite" = {
      location = {
        source_directories = [ "/backups" "/data" "/persistent" ];
        repositories = [ "root@gatebridge:/backup/ds9-offsite" ];
      };
      exclude_if_present = [ ".nobackup" ];
      encryption_passcommand = "cat ${config.age.secrets.borgmaticEncryptionKey.path}";
      compression = "zstd,10";
      upload_rate_limit = "4000";
      ssh_command = "ssh -o GlobalKnownHostsFile=${config.age.secrets.gatebridgeHostKeys.path} -i ${config.age.secrets.ds9OffsiteBackupSSH.path}";
      before_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})/start" ];
      after_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})" ];
      on_error = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})/fail" ];
      postgresql_databases = [ "all" ];
    };
  };

  programs.mosh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  networking.useDHCP = true;
  networking.bridges."br0".interfaces = [ ];
  networking.hostId = "7b4c2932";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
  services.nginx.defaultListenAddresses = [ "100.83.96.25" ];
  services.nginx.clientMaxBodySize = lib.mkForce "8g";
  services.nginx.virtualHosts."_".
  listenAddresses = [ "0.0.0.0" "[::0]" ];
  services.nginx.virtualHosts."h.hailsatan.eu" = {
    listenAddresses = [ "0.0.0.0" "[::0]" ];
    useACMEHost = "hailsatan.eu";
    forceSSL = true;
    locations = {
      "/".proxyPass = "http://192.168.122.76:8123";
      "/".proxyWebsockets = true;
    };
  };
  boot.initrd.network = {
    enable = true;
    postCommands = ''
      zpool import rpool
      zpool import spool
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [
        "/persistent/etc/nixos/secrets/initrd/ssh_host_rsa_key"
        "/persistent/etc/nixos/secrets/initrd/ssh_host_ed25519_key"
      ];
      authorizedKeys = pubkeys.ragon.computers;

    };

  };
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 512;

  services.openssh.sftpServerExecutable = "internal-sftp";
  services.openssh.extraConfig = ''
    Match User picardbackup
      ChrootDirectory ${config.users.users.picardbackup.home}
      ForceCommand internal-sftp
      AllowTcpForwarding no
  '';

  # Backup Target
  users.users.picardbackup = {
    createHome = false;
    group = "users";
    uid = 993;
    home = "/backups/restic/picard";
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvCF8KGgpF9O8Q7k+JXqZ5eMeEeTaMhCIk/2ZFOzXL0"
    ];
  };


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
  #systemd.services.scanhook = {
  #  description = "webhook go server to trigger scanning";
  #  documentation = [ "https://github.com/adnanh/webhook" ];
  #  wantedBy = [ "multi-user.target" ];
  #  path = with pkgs; [ bash ];
  #  serviceConfig = {
  #    TemporaryFileSystem = "/:ro";
  #    BindReadOnlyPaths = [
  #      "/nix/store"
  #      "-/etc/resolv.conf"
  #      "-/etc/nsswitch.conf"
  #      "-/etc/hosts"
  #      "-/etc/localtime"
  #    ];
  #    BindPaths = [
  #      "/data/applications/paperless-consumption"
  #    ];
  #    LockPersonality = true;
  #    NoNewPrivileges = true;
  #    PrivateMounts = true;
  #    PrivateTmp = true;
  #    PrivateUsers = true;
  #    ProcSubset = "pid";
  #    ProtectHome = true;
  #    ProtectControlGroups = true;
  #    ProtectKernelLogs = true;
  #    ProtectKernelModules = true;
  #    ProtectKernelTunables = true;
  #    ProtectProc = "invisible";
  #    RestrictNamespaces = true;
  #    RestrictRealtime = true;
  #    RestrictSUIDSGID = true;
  #    DynamicUser = true;
  #    ExecStart =
  #      let
  #        scanScript = pkgs.writeScript "plscan.sh" ''
  #          #!/usr/bin/env bash
  #          export PATH=${lib.makeBinPath [ pkgs.strace pkgs.gnugrep pkgs.coreutils pkgs.sane-backends pkgs.sane-airscan pkgs.imagemagick ]}
  #          export LD_LIBRARY_PATH=${config.environment.sessionVariables.LD_LIBRARY_PATH} # Adds SANE Libraries to the ld library path of this script
  #          set -x
  #          date="''$(date --iso-8601=seconds)"
  #          filename="Scan ''$date.pdf"
  #          tmpdir="''$(mktemp -d)"
  #          pushd "''$tmpdir"
  #          scanimage --batch=out%d.jpg --format=jpeg --mode Gray -d "airscan:e0:Canon MB5100 series" --source "ADF Duplex" --resolution 300
  #          for i in $(ls out*.jpg | grep 'out.*[24680]\.jpg'); do convert $i -rotate 180 $i; done # rotate even stuff
  #          convert out*.jpg /data/applications/paperless-consumption/"''$filename"
  #          chmod 666 /data/applications/paperless-consumption/"''$filename"
  #          popd
  #          rm -r "''$tmpdir"
  #        '';
  #        hooksFile = pkgs.writeText "webhook.json" (builtins.toJSON [
  #          {
  #            id = "scan-webhook";
  #            execute-command = "${scanScript}";

  #          }
  #        ]);
  #      in
  #      "${pkgs.webhook}/bin/webhook -hooks ${hooksFile} -verbose";
  #  };
  #};
  networking.firewall.allowedTCPPorts = [ 9000 25565 ];

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  services.samba.extraConfig = ''
    min protocol = SMB3
    vfs objects = acl_xattr catia fruit streams_xattr
    fruit:nfs_aces = no
    inherit permissions = yes
    fruit:posix_rename = yes
    fruit:resource = xattr
    fruit:model = MacSamba
    fruit:veto_appledouble = no
    fruit:wipe_intentionally_left_blank_rfork = yes 
    fruit:delete_empty_adfiles = yes 
    fruit:metadata = stream
  '';

  users.users.minecraft = {
    description = "Minecraft server service user";
    home = "/var/lib/minecraft";
    createHome = true;
    isSystemUser = true;
    group = "minecraft";
  };
  users.groups.minecraft = { };
  environment.systemPackages = [ pkgs.jdk ];

  services.smartd = {
    enable = true;
    extraOptions = [ "--interval=7200" ];
    #notifications.test = true;
  };
  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.override { enableMail = true; };
    })
  ];

  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 7200;
    #ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = false;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  services.plex = {
    enable = true;
    openFirewall = true;
    user = "ragon";
    group = "users";
  };

  ragon = {
    cli.enable = true;
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/var/lib/syncthing" config.services.plex.dataDir "/var/lib/minecraft" ];

    services = {
      samba.enable = true;
      samba.shares = {
        TimeMachine = {
          path = "/backups/DaedalusTimeMachine";
          comment = "DaedalusTimeMachine";
          "write list" = "@wheel";
          "read only" = "no";
          "writable" = "yes";
          "browseable" = "yes";
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
      msmtp.enable = true;
      photoprism.enable = true;
      tailscale.enable = true;
      tailscale.exitNode = true;
      tailscale.extraUpCommands = "--advertise-routes=10.0.0.0/16";
      grafana.enable = true;
      libvirt.enable = true;
      paperless.enable = true;
    };

  };
}
