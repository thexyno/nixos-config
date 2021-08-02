
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
#        signupsAllowed = false;
        rocketPort = 8222;
        rocketAddress = "127.0.0.1";
        databaseUrl = "postgresql://%2Frun%2Fpostgresql/vaultwarden";
        webVaultEnabled = true;
      };
      dbBackend = "postgresql";

    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/".proxyPass = "http://${config.services.vaultwarden.config.rocketAddress}:${toString config.services.vaultwarden.config.rocketPort}";
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
    ];
  };
}
