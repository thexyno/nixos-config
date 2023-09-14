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
  ragon.agenix.secrets."picardResticPassword" = { };
  ragon.agenix.secrets."picardResticSSHKey" = { };
  ragon.agenix.secrets."picardResticHealthCheckUrl" = { };
  ragon.agenix.secrets."picardSlidingSyncSecret" = { };

  services.nginx.recommendedOptimisation = true;

  services.nginx.virtualHosts."xyno.space" = {
    locations."/".proxyPass = "http://[::1]${config.services.xynoblog.listen}";
    locations."/gyakapyukawfyuokfgwtyutf.js".proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}/js/plausible.outbound-links.js";
    locations."/api/event".proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}";
  } // (lib.my.findOutTlsConfig "xyno.space" config);

  services.lolpizza2.enable = true;

  services.nginx.virtualHosts."lolpizza.ragon.xyz" = {
    useACMEHost = "ragon.xyz";
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]${config.services.lolpizza2.listen}";
  };

  services.nginx.virtualHosts."xyno.systems" = {
    locations."/".return = "307 https://xyno.space$request_uri";
  } // (lib.my.findOutTlsConfig "xyno.systems" config);

  security.acme.certs."xyno.space" = {
    dnsProvider = "ionos";
    dnsResolver = "1.1.1.1:53";
    group = "nginx";
    extraDomainNames = [
      "*.xyno.systems"
    ];
    credentialsFile = "${config.age.secrets.cloudflareAcme.path}";
  };
  security.acme.certs."xyno.systems" = {
    dnsProvider = "ionos";
    dnsResolver = "1.1.1.1:53";
    group = "nginx";
    extraDomainNames = [
      "*.xyno.systems"
    ];
    credentialsFile = "${config.age.secrets.cloudflareAcme.path}";
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

  services.restic.backups."picard" = {
    passwordFile = config.age.secrets.picardResticPassword.path;
    extraOptions = [
      "sftp.command='ssh picardbackup@ds9 -i ${config.age.secrets.picardResticSSHKey.path} -s sftp'"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
    initialize = true;
    repository = "sftp:picardbackup@ds9:/restic";
    paths = [
      "/persistent"
    ];

  };


  systemd.services.restic-backups-picard = {
    # ExecStartPost commands are only run if the ExecStart command succeeded
    serviceConfig.ExecStartPost = pkgs.writeShellScript "backupSuccessful" ''
      ${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.picardResticHealthCheckUrl.path})
    '';
    unitConfig.OnFailure = "backupFailure.service";
  };

  systemd.services.backupFailure = {
    enable = true;
    script = "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(cat ${config.age.secrets.picardResticHealthCheckUrl.path})/fail";
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
      hedgedoc.enable = false;
      ts3.enable = true;
      nginx.enable = true;
      nginx.domain = "ragon.xyz";
      nginx.domains = [ "xyno.space" "xyno.systems" ];
    };

  };

}
