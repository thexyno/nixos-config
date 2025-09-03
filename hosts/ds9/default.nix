{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  pubkeys = import ../../data/pubkeys.nix;
  caddy-with-plugins = import ./custom-caddy.nix { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix

    ./containers.nix
    ./backup.nix
    # ./plex.nix
    ./samba.nix
    ./paperless.nix
    ./maubot.nix
    ./woodpecker.nix
    ./attic.nix
    ./ytdl-sub.nix

    ../../nixos-modules/networking/tailscale.nix
    ../../nixos-modules/services/docker.nix
    ../../nixos-modules/services/libvirt.nix
    ../../nixos-modules/services/msmtp.nix
    # ../../nixos-modules/services/paperless.nix
    # ../../nixos-modules/services/photoprism.nix
    ../../nixos-modules/services/samba.nix
    ../../nixos-modules/services/ssh.nix
    ../../nixos-modules/services/caddy
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
  networking.useNetworkd = true;
  systemd.network.networks."enp1s0f1".ipv6AcceptRAConfig = {
    Token = "prefixstable";
  };
  networking.bridges."br0".interfaces = [ ];
  networking.hostId = "7b4c2932";
  networking.firewall.allowedTCPPorts = [
    9000
    25565
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ]; # http3 :3
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

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  # users.users.nia = {
  #   createHome = true;
  #   isNormalUser = true;
  #   extraGroups = [
  #     "docker"
  #     "podman"
  #     "wheel"
  #   ];
  #   openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDq+jk1Bi8/x0lYDiVi/iVnp9nEleocoQ+xHmlpDt9Qs"
  #   ];
  # };
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
  environment.systemPackages = [
    pkgs.jdk17
    pkgs.borgbackup
    pkgs.beets
  ];

  services.smartd = {
    enable = true;
    extraOptions = [ "--interval=7200" ];
    notifications.test = true;
  };
  

  services.zfs.zed.enableMail = true;
  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 7200;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = false;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  # dyndns

  systemd.services."dyndns-refresh" = {
    script = ''
      set -eu
      export PATH=$PATH:${pkgs.curl}/bin:${pkgs.jq}/bin:${pkgs.iproute2}/bin
      ${pkgs.bash}/bin/bash ${config.age.secrets.ds9DynDns.path}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    startAt = "*:0/10";
  };

  # services.tailscaleAuth.enable = true;
  # services.tailscaleAuth.group = config.services.caddy.group;
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.desec.path;
  services.caddy = {
    # ragon.services.caddy is enabled
    extraConfig = ''
      (blockBots) {
        @botForbidden header_regexp User-Agent "(?i)AdsBot-Google|Amazonbot|anthropic-ai|Applebot|Applebot-Extended|AwarioRssBot|AwarioSmartBot|Bytespider|CCBot|ChatGPT|ChatGPT-User|Claude-Web|ClaudeBot|cohere-ai|DataForSeoBot|Diffbot|FacebookBot|Google-Extended|GPTBot|ImagesiftBot|magpie-crawler|omgili|Omgilibot|peer39_crawler|PerplexityBot|YouBot"

        handle @botForbidden   {
          redir https://hil-speed.hetzner.com/10GB.bin
        }
        handle /robots.txt {
          respond <<TXT
          User-Agent: *
          Disallow: /
          TXT 200
        }
      }
      (podmanRedir) {
        reverse_proxy {args[:]} {
          transport http {
            resolvers 10.88.0.1 # podman dns
          }
        }
      }
      (podmanRedirWithAuth) {
        route {
        # always forward outpost path to actual outpost
          reverse_proxy /outpost.goauthentik.io/* http://authentik-server:9000 {
            transport http {
              resolvers 10.88.0.1 # podman dns
            }
          }
          forward_auth http://authentik-server:9000 {
            transport http {
              resolvers 10.88.0.1 # podman dns
            }
            uri /outpost.goauthentik.io/auth/caddy
            copy_headers X-Authentik-Username X-Copyparty-Group X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version X-Grafana-Role
          }
          reverse_proxy {args[:]} {
            transport http {
              resolvers 10.88.0.1 # podman dns
            }
          }
        }
      }
    '';
    globalConfig = ''
      acme_ca https://acme-v02.api.letsencrypt.org/directory # hard coded so zerossl doesn't get used
      acme_dns desec {
        token "{$TOKEN}"
      }
      metrics {
        per_host
      }
      servers {
        trusted_proxies static 100.96.45.2/32 fd7a:115c:a1e0:ab12:4843:cd96:6260:2d02/128
      }
    '';
    virtualHosts."*.hailsatan.eu ".logFormat = ''
      output file ${config.services.caddy.logDir}/access-*hailsatan.eu_internet.log
    '';
    virtualHosts."*.hailsatan.eu ".extraConfig = ''
      @vanitygpg host vanitygpg.hailsatan.eu
      handle @vanitygpg {
        reverse_proxy h2c://[::1]:29328
      }
      import blockBots
      @jellyfin host j.hailsatan.eu
      handle @jellyfin {
        handle /metrics* {
          abort
        }
        import podmanRedir http://jellyfin:8096 
      }
      @mautrix-signal host mautrix-signal.hailsatan.eu
      handle @mautrix-signal {
        import podmanRedir http://mautrix-signal:29328
      }
      @woodpecker host woodpecker.hailsatan.eu
      handle @woodpecker {
        import podmanRedir http://woodpecker-server:8000
      }
      @attic host attic.hailsatan.eu
      handle @attic {
        reverse_proxy http://[::1]:8089
      }
      @auth host auth.hailsatan.eu
      handle @auth {
        import podmanRedir http://authentik-server:9000
      }
      @grafana host grafana.hailsatan.eu
      handle @grafana {
        import podmanRedirWithAuth http://grafana:3000 
      }
      @hoard host hoard.hailsatan.eu
      handle @hoard {
        import podmanRedirWithAuth http://partdb-server:80
      }
      @immich host immich.hailsatan.eu
      handle @immich {
        import podmanRedir http://immich-server:2283
      }
      @cd host cd.hailsatan.eu
      handle @cd {
        import podmanRedirWithAuth http://changedetection:5000 
      }
      @node-red host node-red.hailsatan.eu
      handle @node-red {
        import podmanRedirWithAuth http://node-red:1880 
      }
      @labello host labello.hailsatan.eu
      handle @labello {
        import podmanRedirWithAuth http://labello:4242
      }
      @paperless host paperless.hailsatan.eu
      handle @paperless {
        import podmanRedirWithAuth http://paperless-server:8000
      }
      @archivebox host archivebox.hailsatan.eu
      handle @archivebox {
        handle /api/* {
          import podmanRedir http://archivebox:8000
        }
        handle {
          import podmanRedirWithAuth http://archivebox:8000 
        }
      }
      @copyparty host c.hailsatan.eu
      handle @copyparty {
        # @proxy {
        #   header_regexp Cookie authentik_proxy_([a-zA-Z0-9])
        # }
        # handle @proxy {
        #   import podmanRedirWithAuth http://copyparty:3923
        # }
        handle /shr/* {
          import podmanRedir http://copyparty:3923
        }
        handle /.cpr/* {
          import podmanRedir http://copyparty:3923
        }
        # @noauth {
        #   path_regexp ^\/(noauth(\/.*|)|[a-z.]+\.(css|js)|[1-9].png)$
        # }
        # @getoptionshead {
        #   method GET OPTIONS HEAD
        # }
        # handle @noauth {
        #   handle @getoptionshead {
        #     import podmanRedir http://copyparty:3923
        #   }
        # }
        handle {
          import podmanRedirWithAuth http://copyparty:3923
        }
      }
      handle {
        import podmanRedirWithAuth http://127.0.0.1:8001
      }
    '';
  };

  services.prometheus = {
    enable = true;
    exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
    };
    exporters.postgres = {
      enable = true;
      environmentFile = config.age.secrets.ds9PostgresExporterEnv.path;
    };
    scrapeConfigs = [
      {
        job_name = "postgres";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.postgres.port}"
              "picard.kangaroo-galaxy.ts.net:${toString config.services.prometheus.exporters.postgres.port}"
            ];
          }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          {
            targets = [
              "localhost:2019"
              "picard.kangaroo-galaxy.ts.net:2019"
            ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
              "picard.kangaroo-galaxy.ts.net:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];
  };

  home-manager.users.ragon =
    {
      pkgs,
      lib,
      inputs,
      config,
      ...
    }:
    {
      imports = [
        # ../../hm-modules/nvim
        ../../hm-modules/helix
        # ../../hm-modules/zsh
        ../../hm-modules/tmux
        # ../../hm-modules/xonsh
        ../../hm-modules/cli.nix
        ../../hm-modules/files.nix
      ];
      # ragon.xonsh.enable = true;

      programs.home-manager.enable = true;
      home.stateVersion = "23.11";
    };

  # begin kube
  # services.k3s = {
  #   enable = true;
  #   extraFlags = "--disable=traefik --cluster-cidr 10.42.0.0/16,2001:cafe:42::/56 --service-cidr=10.43.0.0/16,2001:cafe:43::/112 --vpn-auth-file=/persistent/tailscale-auth-file";
  #};
  # systemd.services.k3s.path =  [pkgs.tailscale pkgs.coreutils pkgs.bash];
  # end kube

  ragon = {
    agenix.secrets."desec" = { };
    agenix.secrets."ds9DynDns" = { };
    agenix.secrets."ds9PostgresExporterEnv" = { };
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [
      "/home/nia"
      "/var/lib/syncthing"
      "/var/lib/minecraft"
      "/var/lib/bzzt"
      "/var/lib/rancher"
      "/etc/rancher"
      "/root/.cache"
      "/var/lib/${config.services.prometheus.stateDir}"
    ];

    services = {
      caddy.enable = true;
      docker.enable = true;
      ssh.enable = true;
      msmtp.enable = true;
      # photoprism.enable = true;
      tailscale.enable = true;
      tailscale.exitNode = true;
      tailscale.extraUpCommands = "--advertise-routes=10.0.0.0/16";
      # libvirt.enable = true;
      # paperless.enable = true;
    };

  };
}
