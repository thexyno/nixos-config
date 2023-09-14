{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.hedgedoc;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.hedgedoc.enable = lib.mkEnableOption "Enables the hedgedoc BitWarden Server";
  options.ragon.services.hedgedoc.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "md.xyno.systems";
    };
  config = lib.mkIf cfg.enable {
    ragon.secrets.autheliaHedgedoc = { user = "authelia"; };
    services.authelia.instances.main.settingsFiles = [
      config.age.secrets.autheliaHedgedoc.path
    ];
    services.hedgedoc = {
      enable = true;
      environmentFile = "${config.age.secrets.hedgedocSecret.path}";
      configuration = {
        protocolUseSSL = true;
        sessionSecret = "$SESSION_SECRET";
        allowAnonymous = false;
        allowAnonymousEdits = false;
        allowFreeURL = true;
        email = false;
        oauth2 = {
          clientID = "$OAUTH2_CLIENT_ID";
          clientSecret = "$OAUTH2_CLIENT_SECRET";
          providerName = "xyno.systems SSO";
          authorizationURL = "https://sso.xyno.systems/oauth2/authorize";
          tokenURL = "https://sso.xyno.systems/oauth2/token";
          userProfileURL = "https://sso.xyno.systems/oauth2/userinfo";
          scope = "openid profile email";
          userProfileUsernameAttr = "sub";
          userProfileEmailAttr = "email";
          userProfileDisplayNameAttr = "name";
        };
        domain = "${cfg.domain}";
        db = {
          dialect = "postgres";
          host = "/run/postgresql";
          database = "hedgedoc";
        };
      };

    };
    ragon.agenix.secrets.hedgedocSecret.owner = "hedgedoc";
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      locations."/".proxyWebsockets = true;
      locations."/".proxyPass = "http://127.0.0.1:${toString config.services.hedgedoc.configuration.port}";
    } // (lib.my.findOutTlsConfig cfg.domain config);
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
