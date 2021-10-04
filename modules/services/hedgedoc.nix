{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.hedgedoc;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.hedgedoc.enable = lib.mkEnableOption "Enables the hedgedoc BitWarden Server";
  options.ragon.services.hedgedoc.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "md";
    };
  config = lib.mkIf cfg.enable {
    services.hedgedoc = {
      enable = true;
      domain = "${cfg.domainPrefix}.${domain}":
      dbURL = "postgresql://%2Frun%2Fpostgresql/hedgedoc";
      allowAnonymousEdits = false;
      allowFreeURL = true;

    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      proxyWebsockets = true;
      useACMEHost = "${domain}";
      locations."/".proxyPass = "http://127.0.0.1:${config.services.hedgedoc.configuration.port}";
    };
    services.postgresql = {
      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "hedgedoc" ];
      ensureUsers = [
        {
          name = "hedgedoc";
          ensurePermissions."DATABASE hedgedoc" = "ALL PRIVILEGES";
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "${config.services.hedgedoc.workDir}"
    ];
  };
}
