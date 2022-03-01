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
      environmentFile = "${config.age.secrets.hedgedocSecret.path}";
      configuration = {
        protocolUseSSL = true;
        sessionSecret = "$SESSION_SECRET";
        allowEmailRegister = false;
        domain = "${cfg.domainPrefix}.${domain}";
        db = {
          dialect = "postgres";
          host = "/run/postgresql";
          database = "hedgedoc";
        };
        allowAnonymousEdits = false;
        allowFreeURL = true;
      };

    };
    ragon.agenix.secrets.hedgedocSecret.owner = "hedgedoc";
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/".proxyWebsockets = true;
      locations."/".proxyPass = "http://127.0.0.1:${toString config.services.hedgedoc.configuration.port}";
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
