# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.systemd-boot.enable = false;

  networking.interfaces."ens3" = {
    ipv6 = {
      addresses = [
        {
          address = "2a00:6800:3:744::1";
          prefixLength = 64;
        }
      ];
    };
    ipv4 = {
      addresses = [
        {
          address = "195.90.211.163";
          prefixLength = 22;
        }
      ];
    };
  };
  networking.defaultGateway6 = { address = "2a00:6800:3::1"; interface = "ens3"; };
  networking.defaultGateway = { address = "195.90.208.1"; interface = "ens3"; };
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.useDHCP = false;
  # networking.interfaces.eno1.useDHCP = true;
  networking.hostId = "7c28236a";

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  services.postgresql.package = pkgs.postgresql_13;

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "beliskner.kangaroo-galaxy.ts.net";
      root_url = "https://beliskner.kangaroo-galaxy.ts.net/";
    };
  };
  services.grafana.settings = {
    analytics.reporting_enabled = false;
    users = {
      allow_sign_up = false;
    };
    #auth.proxy = ''
    #  enabled = true
    #  header_name = "X-Webauth-User"
    #  header_property = "username"
    #  auto_sign_up = true
    #  allow_sign_up = true
    #  whitelist = "127.0.0.1, ::1"
    #'';
  };


  ragon.agenix.secrets."prometheusBlackboxConfig" = { owner = config.services.prometheus.exporters.blackbox.user; };
  users.groups.${config.services.prometheus.exporters.blackbox.user} = { };
  users.users.${config.services.prometheus.exporters.blackbox.user} = {
    isSystemUser = true;
    group = config.services.prometheus.exporters.blackbox.user;
  };
  services.prometheus.exporters.blackbox = {
    enable = true;
    configFile = config.age.secrets.prometheusBlackboxConfig.path;
    enableConfigCheck = false;
  };


  services.caddy = {
    enable = true;
    virtualHosts = {
      "beliskner.kangaroo-galaxy.ts.net" = {
        extraConfig = ''
          #forward_auth unix//run/tailscale/tailscaled.sock {
          #  uri /auth
          #  header_up Remote-Addr {remote_host}
          #  header_up Remote-Port {remote_port}
          #  header_up Original-URI {uri}
          #  copy_headers {
          #    Tailscale-User>X-Webauth-User
          #    Tailscale-Name>X-Webauth-Name
          #    Tailscale-Login>X-Webauth-Login
          #    Tailscale-Tailnet>X-Webauth-Tailnet
          #    Tailscale-Profile-Picture>X-Webauth-Profile-Picture
          #  }
          #}
          reverse_proxy {
            to http://localhost:${toString config.services.grafana.settings.server.http_port}
            flush_interval -1
            transport http {
              keepalive 310s
              compression off
            }
          }
        '';
      };
    };
  };

  networking.firewall.trustedInterfaces = [ "lo" "tailscale0" ];
  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };


  age.identityPaths = lib.mkForce [ "/nix/persistent/etc/ssh/ssh_host_ed25519_key" ];

  ragon = {
    cli.enable = false;
    user.enable = false;
    persist.enable = true;
    persist.baseDir = "/nix/persistent";
    persist.extraDirectories = [
      "/var/lib/tailscale"
      "/var/lib/caddy"
      "/var/log"
    ];
    services = {
      ssh.enable = true;
    };
  };
}
