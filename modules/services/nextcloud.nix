{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.nextcloud;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.nextcloud.enable = mkEnableOption "Enables nextcloud";
  options.ragon.services.nextcloud.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "nextcloud";
    };
  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      https = true;
      hostName = "${cfg.domainPrefix}.${domain}";
      enable = true;
      maxUploadSize = "4G";
      config = {
        adminpassFile = "/run/secrets/nextcloudAdminPass";
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        overwriteProtocol = "https";
      };
      autoUpdateApps.enable = true;

    };
    age.secrets = {
      nextcloudAdminPass.owner = "nextcloud";
    };
    services.postgresql = {
      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
        }
      ];
    };
    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
    };


    ragon.persist.extraDirectories = [
      "${config.services.nextcloud.home}"
      "${config.services.postgresql.dataDir}"
    ];
  };
}
