{ config, inputs, pkgs, lib, ... }:
let
  pubkeys = import ../../data/pubkeys.nix;
  caddy-with-plugins = import ./custom-caddy.nix { inherit pkgs; };
in
{
  imports =
    [
      ./hardware-configuration.nix

      ./containers.nix
      ./backup.nix
      # ./plex.nix
      ./samba.nix

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
  networking.firewall.allowedTCPPorts = [ 9000 25565 80 443 ];
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

  users.users.nia = {
    createHome = true;
    isNormalUser = true;
    extraGroups = [ "docker" "podman" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDq+jk1Bi8/x0lYDiVi/iVnp9nEleocoQ+xHmlpDt9Qs"
    ];
  };
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
  environment.systemPackages = [ pkgs.jdk17 pkgs.borgbackup pkgs.beets ];

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
      }
      (podmanRedir) {
        reverse_proxy {args[:]} {
          transport http {
            resolvers 10.88.0.1 # podman dns
          }
        }
      }
    '';
    globalConfig = ''
      acme_dns desec {
        token "{$TOKEN}"
      }
    '';
    virtualHosts."*.hailsatan.eu ".logFormat = ''
      output file ${config.services.caddy.logDir}/access-*hailsatan.eu_internet.log
    '';
    virtualHosts."*.hailsatan.eu ".extraConfig = ''
      import blockBots
      @jellyfin host j.hailsatan.eu
      handle @jellyfin {
        import podmanRedir http://jellyfin:8096 
      }
      @auth host auth.hailsatan.eu
      handle @auth {
        import podmanRedir http://authentik-server:9000
      }
      handle {
        abort
      }
      
    '';
    virtualHosts."*.hailsatan.eu".extraConfig = ''
      import blockBots
      # tailscale only
      bind [fd7a:115c:a1e0:ab12:4843:cd96:6253:6019]
      @immich host immich.hailsatan.eu
      handle @immich {
        import podmanRedir http://immich-server:2283
      }
      @cd host cd.hailsatan.eu
      handle @cd {
        import podmanRedir http://changedetection:5000 
      }
      @grafana host grafana.hailsatan.eu
      handle @grafana {
        import podmanRedir http://grafana:3000 
      }
      @node-red host node-red.hailsatan.eu
      handle @node-red {
        import podmanRedir http://node-red:1880 
      }
      @labello host labello.hailsatan.eu
      handle @labello {
        import podmanRedir http://labello:4242
      }

      
      # @bzzt-api host bzzt-api.hailsatan.eu
      # handle @bzzt-api {
      #   reverse_proxy http://127.0.0.1:5001
      # }
      # @bzzt-lcg host bzzt-lcg.hailsatan.eu
      # handle @bzzt-lcg {
      #   reverse_proxy http://127.0.0.1:5003
      # }
      # @bzzt host bzzt.hailsatan.eu
      # handle @bzzt {
      #   reverse_proxy http://127.0.0.1:5002
      # }
      
      
      @archivebox host archivebox.hailsatan.eu
      handle @archivebox {
        import podmanRedir http://archivebox:8000 
      }
      @jellyfin host j.hailsatan.eu
      handle @jellyfin {
        import podmanRedir http://jellyfin:8096 
      }
      handle {
        reverse_proxy http://127.0.0.1:8001
      }
    '';
  };

  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
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
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/home/nia" "/var/lib/syncthing" "/var/lib/minecraft" "/var/lib/bzzt" "/var/lib/rancher" "/etc/rancher" "/root/.cache" ];

    services = {
      caddy.enable = true;
      docker.enable = true;
      ssh.enable = true;
      msmtp.enable = true;
      # photoprism.enable = true;
      tailscale.enable = true;
      tailscale.exitNode = true;
      tailscale.extraUpCommands = "--advertise-routes=10.0.0.0/16";
      libvirt.enable = true;
      # paperless.enable = true;
    };

  };
}
