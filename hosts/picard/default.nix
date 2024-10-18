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
      ./obsidianshare.nix
      # ./ts-ovpn.nix

      ../../nixos-modules/system/persist.nix
      ../../nixos-modules/system/agenix.nix
      ../../nixos-modules/system/fs.nix
      ../../nixos-modules/system/security.nix
      ../../nixos-modules/services/ssh.nix
      ../../nixos-modules/services/msmtp.nix
      ../../nixos-modules/services/caddy
      ../../nixos-modules/services/bitwarden.nix
      ../../nixos-modules/networking/tailscale.nix
      ../../nixos-modules/services/authelia.nix
      ../../nixos-modules/services/hedgedoc.nix
      ../../nixos-modules/services/ts3.nix
      ../../nixos-modules/user
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
  networking.firewall.allowedTCPPorts = [ 80 443 config.services.forgejo.settings.server.SSH_PORT ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  services.caddy = {
    logFormat = "level INFO";
    enable = true;
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
      @git host git.xyno.systems
      handle @git {
        reverse_proxy http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}
      }
      @notes host notes.xyno.systems
      handle @notes {
        reverse_proxy http://127.0.0.1:8086
      }
      
      handle {
        abort
      }
    '';
    virtualHosts."xyno.systems".extraConfig = ''
      redir https://xyno.space{uri}
    '';
    virtualHosts."czi.dating".extraConfig = ''
      redir https://foss-ag.de{uri}
    '';
  };

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings = {
      global.APP_NAME = "xyno.systems git";
      session.COOKIE_SECURE = true;
      server.DOMAIN = "git.xyno.systems";
      server.ROOT_URL = "https://git.xyno.systems/";
      server.HTTP_PORT = 3031;
      server.HTTP_HOST = "127.0.0.1";
      service.DISABLE_REGISTRATION = false;
      service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
      service.SHOW_REGISTRATION_BUTTON = false;

      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = true;
        WHITELISTED_URIS = "sso.xyno.systems";
      };

    };
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

  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
    imports = [
      # ../../hm-modules/nvim
      # ../../hm-modules/zsh
      ../../hm-modules/tmux
      ../../hm-modules/cli.nix
      ../../hm-modules/files.nix
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "23.11";
  };

  ragon = {
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/var/lib/nixos-containers" "/srv/www" config.services.caddy.dataDir "/var/lib/syncthing" "/var/lib/${config.services.xynoblog.stateDirectory}" "/var/lib/postgresql" config.services.forgejo.stateDir ];

    services = {
      caddy.enable = true;
      ssh.enable = true;
      msmtp.enable = true;
      bitwarden.enable = true;
      tailscale.enable = true;
      hedgedoc.enable = true;
      authelia.enable = true;
      ts3.enable = true;
    };

  };

}
