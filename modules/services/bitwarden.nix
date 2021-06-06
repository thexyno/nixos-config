
{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.bitwarden;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.bitwarden.enable = lib.mkEnableOption "Enables the bitwarden_rs BitWarden Server";
  options.ragon.services.bitwarden.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "bw";
    };
  config = lib.mkIf cfg.enable {
    services.bitwarden_rs = {
      enable = true;
      config = {
        domain = "https://${cfg.domainPrefix}.${domain}";
        signupsAllowed = false;
        rocketPort = 8222;
        databaseUrl = "postgresql://%2Frun%2Fpostgresql/bitwarden_rs";
      };
      dbBackend = "postgresql";

    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      locations."/".proxyPass = "http://localhost:${toString config.services.bitwarden_rs.config.rocketPort}";
    };
    services.postgresql = {
      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "bitwarden_rs" ];
      ensureUsers = [
        {
          name = "bitwarden_rs";
          ensurePermissions."DATABASE bitwarden_rs" = "ALL PRIVILEGES";
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "/var/lib/bitwarden_rs"
    ];
  };
}
