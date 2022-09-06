# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

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
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = false;

  services.syncthing.enable = true;


  networking.interfaces."ens3" = {
    ipv6 = {
      addresses = [
        {
          address = "2a03:4000:54:a98::1";
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

  services.nginx.virtualHosts."xyno.space" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]${config.services.xynoblog.listen}";
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
  services.xynoblog.enable = true;
  boot.zfs.package = lib.mkForce (pkgs.zfs.override { enableMail = true; });
  services.zfs.zed.enableMail = true;
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
    };

  };

}
