{ config, inputs, pkgs, lib, ... }:
let
  pubkeys = import ../../data/pubkeys.nix;
  caddy-with-plugins = import ./custom-caddy.nix { inherit pkgs; };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./backup.nix
      ./plex.nix
      ./hardware-configuration.nix

      ../../nixos-modules/networking/tailscale.nix
      ../../nixos-modules/services/docker.nix
      ../../nixos-modules/services/libvirt.nix
      ../../nixos-modules/services/msmtp.nix
      ../../nixos-modules/services/paperless.nix
      ../../nixos-modules/services/photoprism.nix
      ../../nixos-modules/services/samba.nix
      ../../nixos-modules/services/ssh.nix
      ../../nixos-modules/system/agenix.nix
      ../../nixos-modules/system/fs.nix
      ../../nixos-modules/system/persist.nix
      ../../nixos-modules/system/security.nix
      ../../nixos-modules/user
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

  programs.mosh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  networking.useDHCP = true;
  networking.bridges."br0".interfaces = [ ];
  networking.hostId = "7b4c2932";
  networking.firewall.allowedTCPPorts = [ 9000 25565 ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
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
        <host-name>ds9.kangaroo-galaxy.ts.net</host-name>
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
        <host-name>ds9.kangaroo-galaxy.ts.net</host-name>
      </service>
    </service-group>
  '';

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

  users.users.bzzt = {
    description = "bzzt server service user";
    home = "/var/lib/bzzt";
    createHome = true;
    isSystemUser = true;
    group = "bzzt";
  };
  users.groups.bzzt = { };
  users.users.minecraft = {
    description = "Minecraft server service user";
    home = "/var/lib/minecraft";
    createHome = true;
    isSystemUser = true;
    group = "minecraft";
  };
  users.groups.minecraft = { };
  environment.systemPackages = [ pkgs.jdk pkgs.jdk17 pkgs.borgbackup pkgs.docker-compose pkgs.docker ];

  services.smartd = {
    enable = true;
    extraOptions = [ "--interval=7200" ];
    notifications.test = true;
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
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = false;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.ionos.path;
  services.caddy = {
    enable = true;
    package = caddy-with-plugins;
    globalConfig = ''
      acme_dns ionos {
        api_token "{$IONOS_API_KEY}"
      }
    '';
    virtualHosts."*.hailsatan.eu".extraConfig = ''
      @paperless host paperless.hailsatan.eu
      handle @paperless {
        reverse_proxy ${config.ragon.services.paperless.location}
      }
      @photos host photos.hailsatan.eu
      handle @photos {
        reverse_proxy ${config.ragon.services.photoprism.location}
      }
      @bzzt-api host bzzt-api.hailsatan.eu
      handle @bzzt-api {
        reverse_proxy http://127.0.0.1:5001
      }
      @bzzt-lcg host bzzt-lcg.hailsatan.eu
      handle @bzzt-lcg {
        reverse_proxy http://127.0.0.1:5003
      }
      @bzzt host bzzt.hailsatan.eu
      handle @bzzt {
        reverse_proxy http://127.0.0.1:5002
      }
    '';
  };

  ragon = {
    agenix.secrets."ionos" = { };
    cli.enable = true;
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/var/lib/syncthing" config.services.plex.dataDir "/var/lib/minecraft" "/var/lib/bzzt" ];

    services = {
      docker.enable = true;
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
