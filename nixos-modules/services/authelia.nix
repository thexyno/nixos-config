{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.authelia;
  instanceName = "main";
  stateDir = "/var/lib/authelia-${instanceName}";
in
{
  options.ragon.services.authelia.enable = lib.mkEnableOption "Enables the authelia SSO Server";
  options.ragon.services.authelia.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "sso.xyno.systems";
    };
  config = lib.mkIf cfg.enable {

    ragon.agenix.secrets.autheliaStorageEncryption = { owner = "authelia-main"; };
    ragon.agenix.secrets.autheliaSessionSecret = { owner = "authelia-main"; };
    ragon.agenix.secrets.autheliaOidcIssuerPrivateKey = { owner = "authelia-main"; };
    ragon.agenix.secrets.autheliaOidcHmacSecret = { owner = "authelia-main"; };
    ragon.agenix.secrets.autheliaJwtSecret = { owner = "authelia-main"; };
    ragon.agenix.secrets.autheliaEmail = { owner = "authelia-main"; };
    services.authelia.instances.${instanceName} = {
      enable = true;
      secrets = {
        storageEncryptionKeyFile = config.age.secrets.autheliaStorageEncryption.path;
        sessionSecretFile = config.age.secrets.autheliaSessionSecret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.autheliaOidcIssuerPrivateKey.path;
        oidcHmacSecretFile = config.age.secrets.autheliaOidcHmacSecret.path;
        jwtSecretFile = config.age.secrets.autheliaJwtSecret.path;
      };
      settingsFiles = [
        config.age.secrets.autheliaEmail.path
      ];
      settings = {
        theme = "auto";
        default_2fa_method = "webauthn";
        access_control = {
          default_policy = "one_factor";
        };
        authentication_backend = {
          file = {
            path = "${stateDir}/users.yml";
          };
        };
        session = {
          domain = cfg.domain;
        };
        storage = {
          postgres = {
            host = "/run/postgresql";
            port = "5432";
            database = "authelia";
            username = "authelia-main";
            password = "dosentmatter";
          };
        };

      };
    };
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
          name = "authelia-main";
          #ensureDBOwnership = true;
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "${stateDir}"
    ];
  };
}
