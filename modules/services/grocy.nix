{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.grocy;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.grocy.enable = lib.mkEnableOption "Enables grocy";
  options.ragon.services.grocy.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "grocy";
    };
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = { # all other settings get set by services.grocy
      forceSSL = true;
      useACMEHost = "${domain}";
    };
    services.grocy = {
      enable = true;
      nginx.enableSSL = false;
      hostName = "${cfg.domainPrefix}.${domain}";
      settings = {
        currency = "EUR";
        culture = "de";
        calendar.firstDayOfWeek = 1;
      };
    };
    ragon.persist.extraDirectories = [
      "${config.services.grocy.dataDir}"
    ];
  };
}
