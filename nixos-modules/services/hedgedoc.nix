{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.hedgedoc;
in
{
  options.ragon.services.hedgedoc.enable = lib.mkEnableOption "Enables the hedgedoc BitWarden Server";
  options.ragon.services.hedgedoc.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "md.xyno.systems";
    };
  config = lib.mkIf cfg.enable {
    # ragon.agenix.secrets.autheliaHedgedoc = { owner = "authelia-main"; };
    # services.authelia.instances.main.settingsFiles = [
    #   config.age.secrets.autheliaHedgedoc.path
    # ];
    services.hedgedoc = {
      enable = true;
      environmentFile = "${config.age.secrets.hedgedocSecret.path}";
      settings = {
        protocolUseSSL = true;
        sessionSecret = "$SESSION_SECRET";
        allowAnonymous = false;
        allowAnonymousEdits = false;
        allowFreeURL = true;
        email = false;
        oauth2 = {
          providerName = "authentik";
          clientID = "$CLIENT_ID";
          clientSecret = "$CLIENT_SECRET";
          scope = "openid email profile";
          userProfileURL = "https://auth.hailsatan.eu/application/o/userinfo/";
          tokenURL = "https://auth.hailsatan.eu/application/o/token/";
          authorizationURL = "https://auth.hailsatan.eu/application/o/authorize/";
          userProfileUsernameAttr = "preferred_username";
          userProfileDisplayNameAttr = "name";
          userProfileEmailAttr = "email";
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
    services.postgresql = {

      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "hedgedoc" ];
      ensureUsers = [
        {
          name = "hedgedoc";
          ensureDBOwnership = true;
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "/var/lib/hedgedoc"
    ];
  };
}
