# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xynospace-matrix.nix
      ./plausible.nix
    ];

  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = false;

  services.syncthing.enable = true;


  networking.interfaces."ens3" = {
    ipv6 = {
      addresses = [
        {
          address = "2a03:4000:6:8120::1";
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

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.desec.path;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.caddy = {
    logFormat = "level INFO";
    enable = true;
    package = (pkgs.callPackage ./custom-caddy.nix {
      externalPlugins = [
        { name = "desec"; repo = "github.com/caddy-dns/desec"; version = "e1e64971fe34c29ce3f4176464adb84d6890aa50"; }
      ];
      vendorHash = "sha256-WWMR4ZpUcDmIv355LBuN5TqVfiCc0+Byxw8LnYei4fs=";
    });
    globalConfig = ''
      acme_dns desec {
        token "{$TOKEN}"
      }
    '';
    virtualHosts."*.ragon.xyz".extraConfig = ''
      @8081 host 8081.ragon.xyz
      handle @8081 {
        reverse_proxy http://[::1]:8081
      }
      @lolpizza host lolpizza.ragon.xyz
      handle @lolpizza {
        reverse_proxy http://[::1]${config.services.lolpizza2.listen}
      }
      @files host files.ragon.xyz
      handle @files {
        encode zstd gzip
        root * /srv/www
        file_server browse
        basicauth * {
          {$BAUSER} {$BAPASSWD}
        }
      }
      @bw host bw.ragon.xyz
      handle @bw {
        reverse_proxy http://${config.services.vaultwarden.config.rocketAddress}:${toString config.services.vaultwarden.config.rocketPort}
      }

      handle {
        abort
      }
    '';
    virtualHosts."xyno.space".extraConfig =
      let
        fqdn = "matrix.xyno.space";
        wkServer = { "m.server" = "${fqdn}:443"; };
        wkClient = {
          "m.homeserver" = { "base_url" = "https://${fqdn}"; };
          "m.identity_server" = { "base_url" = "https://vector.im"; };
          # "org.matrix.msc3575.proxy" = { "url" = "https://slidingsync.ragon.xyz"; };
        };
      in
      ''
        encode zstd gzip
        handle /.well-known/matrix/server {
           header Content-Type application/json
           respond `${builtins.toJSON wkServer}` 200
        }
        handle /.well-known/matrix/client {
           header Content-Type application/json
           header Access-Control-Allow-Origin "*"
           respond `${builtins.toJSON wkClient}` 200
        }
        handle /gyakapyukawfyuokfgwtyutf.js {
           rewrite * /js/plausible.outbound-links.js
           reverse_proxy http://127.0.0.1:${toString config.services.plausible.server.port}
        }
        handle /api/event {
          reverse_proxy http://127.0.0.1:${toString config.services.plausible.server.port}
        }

        reverse_proxy http://[::1]${config.services.xynoblog.listen}
      '';
    virtualHosts."*.xyno.space".extraConfig = ''
      @stats host stats.xyno.space
      handle @stats {
        reverse_proxy http://127.0.0.1:${toString config.services.plausible.server.port}
      }
      @matrix host matrix.xyno.space
      handle @matrix {
        handle /_matrix/* {
          reverse_proxy http://192.168.100.11:8008
        }
        handle /notifications {
          reverse_proxy http://192.168.100.11:8008
        }
        handle /_synapse/client/* {
          reverse_proxy http://192.168.100.11:8008
        }
        handle /health {
          reverse_proxy http://192.168.100.11:8008
        }
      }
      handle {
        abort
      }
    '';
    virtualHosts."*.xyno.systems".extraConfig = ''
      @md host md.xyno.systems
      handle @md {
        reverse_proxy http://[::1]:${toString config.services.hedgedoc.settings.port}
      }
      @sso host sso.xyno.systems
      handle @sso {
        reverse_proxy http://127.0.0.1:${toString config.services.authelia.instances.main.settings.server.port}
      }
      handle {
        abort
      }
    '';
    virtualHosts."xyno.systems".extraConfig = ''
      redir https://xyno.space{uri}
    '';
    virtualHosts."graph.czi.dating".extraConfig = ''
      redir https://graph-czi-dating-s8tan-01d008685713bd0312de3223b3b980279b0ca590.fspages.org{uri}
    '';
    virtualHosts."czi.dating".extraConfig = ''
      redir https://foss-ag.de{uri}
    '';
  };

  ragon.agenix.secrets."desec" = { };

  ragon.agenix.secrets."picardResticPassword" = { };
  ragon.agenix.secrets."picardResticSSHKey" = { };
  ragon.agenix.secrets."picardResticHealthCheckUrl" = { };
  ragon.agenix.secrets."picardSlidingSyncSecret" = { };
  ragon.agenix.secrets."gatebridgeHostKeys" = { };
  services.postgresql.ensureUsers = [
    {
      name = "root";
      ensureClauses.superuser = true;
    }
  ];
  services.borgmatic = {
    enable = true;
    configurations."picard-ds9" = {
      source_directories = [ "/persistent" ];
      repositories = [
        { label = "ds9"; path = "ssh://picardbackup@ds9/backups/picard/borgmatic"; }
        { label = "gatebridge"; path = "ssh://root@gatebridge/media/backup/picard"; }
      ];
      exclude_if_present = [ ".nobackup" ];
      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticPassword.path}";
      compression = "auto,zstd,10";
      ssh_command = "ssh -o GlobalKnownHostsFile=${config.age.secrets.gatebridgeHostKeys.path} -i ${config.age.secrets.picardResticSSHKey.path}";
      retention = {
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
        keep_yearly = 10;
      };
      before_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})/start" ];
      after_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})" ];
      on_error = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})/fail" ];
      postgresql_databases = [{ name = "all"; pg_dump_command = "${pkgs.postgresql}/bin/pg_dumpall"; pg_restore_command = "${pkgs.postgresql}/bin/pg_restore"; }];
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.override { enableMail = true; };
    })
  ];
  services.xynoblog.enable = true;
  services.lolpizza2.enable = true;
  programs.mosh.enable = true;
  ragon = {
    cli.enable = true;
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/srv/www" config.services.caddy.dataDir "/var/lib/syncthing" "/var/lib/${config.services.xynoblog.stateDirectory}" "/var/lib/postgresql" ];

    services = {
      ssh.enable = true;
      msmtp.enable = true;
      bitwarden.enable = true;
      synapse.enable = false;
      tailscale.enable = true;
      hedgedoc.enable = true;
      authelia.enable = true;
      ts3.enable = true;
      nginx.enable = false;
      nginx.domain = "ragon.xyz";
      nginx.domains = [ "xyno.space" "xyno.systems" "czi.dating" ];
    };

  };

}
