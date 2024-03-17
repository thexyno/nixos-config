{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.bitwarden;
in
{
  options.ragon.services.bitwarden.enable = lib.mkEnableOption "Enables the vaultwarden BitWarden Server";
  options.ragon.services.bitwarden.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "bw.ragon.xyz";
    };
  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.unstable.vaultwarden;
      #backupDir = "/persistent/backups/vaultwarden";
      config = {
        domain = "https://${cfg.domain}";
        signupsAllowed = true;
        rocketPort = 8222;
        rocketAddress = "127.0.0.1";
        databaseUrl = "postgresql://%2Frun%2Fpostgresql/vaultwarden";
        webVaultEnabled = true;
      };
      dbBackend = "postgresql";

    };
    services.postgresql = {
      enable = true;

      # Ensure the database, user, and permissions always exist
      ensureDatabases = [ "vaultwarden" ];
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
    };
    ragon.persist.extraDirectories = [
      "/var/lib/bitwarden_rs"
    ];
  };
}
