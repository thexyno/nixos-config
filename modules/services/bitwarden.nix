
{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.bitwarden;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.bitwarden.enable = lib.mkEnableOption "Enables the vaultwarden BitWarden Server";
  options.ragon.services.bitwarden.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "bw";
    };
  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
#      backupDir = "/backups/vaultwarden";
      config = {
        domain = "https://${cfg.domainPrefix}.${domain}";
        signupsAllowed = false;
        rocketPort = 8222;
        databaseUrl = "postgresql://%2Frun%2Fpostgresql/vaultwarden";
      };
      dbBackend = "postgresql";

    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      locations."/".proxyPass = "http://localhost:${toString config.services.vaultwarden.config.rocketPort}";
    };
    services.postgresql = {
      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "vaultwarden" ];
      ensureUsers = [
        {
          name = "vaultwarden";
          ensurePermissions."DATABASE vaultwarden" = "ALL PRIVILEGES";
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "/var/lib/vaultwarden"
      "/backups/vaultwarden"
    ];
  };
}
