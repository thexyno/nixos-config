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

  services.nginx.recommendedOptimisation = true;

  services.nginx.virtualHosts."xyno.space" = {
    locations."/".proxyPass = "http://[::1]${config.services.xynoblog.listen}";
    locations."/gyakapyukawfyuokfgwtyutf.js".proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}/js/plausible.outbound-links.js";
    locations."= /api/event" = {
      proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}/api/event";
      recommendedProxySettings = false;
      extraConfig = ''
        proxy_set_header Host stats.xyno.space;
        proxy_buffering on;
        proxy_http_version 1.1;

        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
      '';
    };
  } // (lib.my.findOutTlsConfig "xyno.space" config);

  services.lolpizza2.enable = true;

  services.nginx.virtualHosts."8001.ragon.xyz" = {
    useACMEHost = "ragon.xyz";
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:8001";
  };
  services.nginx.virtualHosts."lolpizza.ragon.xyz" = {
    useACMEHost = "ragon.xyz";
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]${config.services.lolpizza2.listen}";
  };

  services.nginx.virtualHosts."xyno.systems" = {
    locations."/".return = "307 https://xyno.space$request_uri";
  } // (lib.my.findOutTlsConfig "xyno.systems" config);

  services.nginx.virtualHosts."czi.dating" = {
    locations."/".return = "307 https://foss-ag.de$request_uri";
    forceSSL = true;
    enableACME = true;
  };

  security.acme.certs."xyno.space" = {
    dnsProvider = "ionos";
    dnsResolver = "1.1.1.1:53";
    group = "nginx";
    extraDomainNames = [
      "*.xyno.space"
    ];
    credentialsFile = "${config.age.secrets.cloudflareAcme.path}";
  };
  ragon.agenix.secrets."desec" = { };
  security.acme.certs."xyno.systems" = {
    dnsProvider = "desec";
    dnsResolver = "1.1.1.1:53";
    group = "nginx";
    extraDomainNames = [
      "*.xyno.systems"
    ];
    credentialsFile = "${config.age.secrets.desec.path}";
  };

  services.nginx.appendHttpConfig = ''
    map $remote_addr $ip_anonym1 {
     default 0.0.0;
     "~(?P<ip>(\d+)\.(\d+)\.(\d+))\.\d+" $ip;
     "~(?P<ip>[^:]+:[^:]+):" $ip;
    }

    map $remote_addr $ip_anonym2 {
     default .0;
     "~(?P<ip>(\d+)\.(\d+)\.(\d+))\.\d+" .0;
     "~(?P<ip>[^:]+:[^:]+):" ::;
    }

    map $ip_anonym1$ip_anonym2 $ip_anonymized {
     default 0.0.0.0;
     "~(?P<ip>.*)" $ip;
    }

    log_format anonymized '$ip_anonymized - $remote_user [$time_local] '
       '"$request" $status $body_bytes_sent '
       '"$http_referer" "$http_user_agent"';

    access_log /var/log/nginx/access.log anonymized;
  '';

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
      location = {
        source_directories = [ "/persistent" ];
        repositories = [
          "ssh://picardbackup@ds9/backups/picard/borgmatic"
          "ssh://root@gatebridge/media/backup/picard"
        ];
        exclude_if_present = [ ".nobackup" ];
      };
      storage = {
        encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticPassword.path}";
        compression = "auto,zstd,10";
        ssh_command = "ssh -o GlobalKnownHostsFile=${config.age.secrets.gatebridgeHostKeys.path} -i ${config.age.secrets.picardResticSSHKey.path}";
      };
      retention = {
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
        keep_yearly = 10;
      };
      hooks = {
        before_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})/start" ];
        after_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})" ];
        on_error = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})/fail" ];
        postgresql_databases = [{ name = "all"; pg_dump_command = "${pkgs.postgresql}/bin/pg_dumpall"; pg_restore_command = "${pkgs.postgresql}/bin/pg_restore"; }];
      };
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.override { enableMail = true; };
    })
  ];
  services.xynoblog.enable = true;
  programs.mosh.enable = true;
  ragon = {
    cli.enable = true;
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/var/lib/syncthing" "/var/lib/${config.services.xynoblog.stateDirectory}" ];

    services = {
      ssh.enable = true;
      msmtp.enable = true;
      bitwarden.enable = true;
      gitlab.enable = false; # TODO gitlab-runner
      synapse.enable = true;
      tailscale.enable = true;
      hedgedoc.enable = true;
      authelia.enable = true;
      ts3.enable = true;
      nginx.enable = true;
      nginx.domain = "ragon.xyz";
      nginx.domains = [ "xyno.space" "xyno.systems" "czi.dating" ];
    };

  };

}
