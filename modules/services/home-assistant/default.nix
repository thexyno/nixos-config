{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.home-assistant;
  domain = config.ragon.nginx.domain;
in
{
  options.ragon.services.home-assistant.enable = lib.mkEnableOption "Enables hass";
  options.ragon.services.home-assistant.domainPrefix = 
    lib.mkOption {
      type = lib.types.str;
      default = "h";
    };
  config = lib.mkIf cfg.enable {
    # https://github.com/Mic92/dotfiles/tree/master/nixos/eve/modules/home-assistant for orientation
    services.home-assistant = {
      enable = true;
      package = pkgs.home-assistant.override {
        extraPackages = ps: [
          ps.psycopg2
        ];
      };
      config.recorder.db_url = "postgresql://@/hass";
      applyDefaultConfig = false;

    };
    
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensurePermissions = {
          "DATABASE hass" = "ALL PRIVILEGES";
        };
      }];
    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      addSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };

    ragon.persist.extraDirectories = [
      "/var/lib/hass"
      "${config.services.postgresql.dataDir}"
    ];
  };
}
