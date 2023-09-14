{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.authelia;
  stateDir = "/var/lib/authelia";
  instanceName = "main";
in
{
  options.ragon.services.authelia.enable = lib.mkEnableOption "Enables the authelia SSO Server";
  options.ragon.services.authelia.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "sso.xyno.systems";
    };
  config = lib.mkIf cfg.enable {

    ragon.secrets.autheliaStorageEncryption = { };
    ragon.secrets.autheliaSessionSecret = { };
    ragon.secrets.autheliaOidcIssuerPrivateKey = { };
    ragon.secrets.autheliaOidcHmacSecret = { };
    ragon.secrets.autheliaJwtSecret = { };
    ragon.secrets.autheliaEmail = { user = "authelia"; };
    services.authelia.instances.${instanceName} = {
      enable = true;
      secrets = {
        storageEncryptionKeyFile = config.age.secrets.autheliaStorageEncryption.path;
        sessionSecretFile = config.age.secrets.autheliaSessionSecret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.autheliaOidcIssuerPrivateKey.path;
        oidcHmacSecretFile = config.age.secrets.autheliaOidcHmacSecret.path;
        jwtSecretFile = config.age.secrets.autheliaJwtSecret.path;
      };
      settingstFiles = [
        config.age.secrets.autheliaEmail.path
      ];
      settings = {
        theme = "auto";
        default_2fa_method = "webauthn";
        authentication_backend = {
          file = {
            path = "${stateDir}/users.yml";
          };
        };
        storage = {
          postgres = {
            host = "/run/postgresql";
          };
        };
        notifier = {
          smtp = {
            address = "smtp://smtp.ionos.de:465";
            sender = "xyno.systems SSO <machdas@xyno.space>";
            username = "machdas@xyno.space";
            subject = "[xyno.systems SSO] {title}";
            startup_check_address = "autodelete@phochkamp.de";
          };
        };

      };
    };
    systemd.tmpfiles.rules = [
      "d ${stateDir} 0755 authelia authelia -"
    ];
    ragon.agenix.secrets.autheliaSecret.owner = "authelia";
    services.nginx.virtualHosts."${cfg.domain}" = {
      locations."/".proxyWebsockets = true;
      locations."/".proxyPass = "http://127.0.0.1:${toString config.services.authelia.instances.${instanceName}.settings.server.port}";
    } // (lib.my.findOutTlsConfig cfg.domain config);
    services.postgresql = {
      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "authelia" ];
      ensureUsers = [
        {
          name = "authelia";
          ensurePermissions."DATABASE authelia" = "ALL PRIVILEGES";
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "${stateDir}"
    ];
  };
}
