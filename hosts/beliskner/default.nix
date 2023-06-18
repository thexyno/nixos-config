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
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = false;

  #networking.interfaces."ens3" = {
  #  ipv6 = {
  #    addresses = [
  #      {
  #        address = "2a03:4000:54:a98::1";
  #        prefixLength = 64;
  #      }
  #    ];
  #  };
  #};
  #networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s3"; };
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
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


  ragon.agenix.secrets."prometheusBlackboxConfig" = { owner = config.services.prometheus.exporters.blackbox.user; };
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
                    reverse_proxy :${toString config.services.grafana.settings.server.http_port}
                    forward_auth unix//run/tailscale.nginx-auth.sock {
          	      uri /auth
          	      header_up Remote-Addr {remote_host}
          	      header_up Remote-Port {remote_port}
          	      header_up Original-URI {uri}
          	      copy_headers {
               	        Tailscale-User>X-Webauth-User
          	        Tailscale-Name>X-Webauth-Name
          	        Tailscale-Login>X-Webauth-Login
          	        Tailscale-Tailnet>X-Webauth-Tailnet
          	        Tailscale-Profile-Picture>X-Webauth-Profile-Picture
          	      }
                    }
        '';
      };
    };
  };

  networking.firewall.trustedInterfaces = [ "lo" "tailscale0" ];
  services.grafana.settings = {
    analytics.reporting_enabled = false;
    users = {
      allow_sign_up = false;
    };
    auth.proxy = ''
      enabled = true
      header_name = "X-Webauth-User"
      header_property = "username"
      auto_sign_up = true
      allow_sign_up = true
      whitelist = "127.0.0.1, ::1"
    '';
  };
  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };



  ragon = {
    cli.enable = false;
    user.enable = false;
    persist.enable = true;
    persist.extraDirectories = [
      "/var/lib/tailscale"
      "/var/lib/caddy"
    ];
    services = {
      ssh.enable = true;
    };
  };
}
