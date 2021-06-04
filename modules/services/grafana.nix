{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.grafana;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.grafana.enable = lib.mkEnableOption "Enables grafana";
  options.ragon.services.grafana.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "grafana";
    };
  config = lib.mkIf cfg.enable {
    services.grafana = {

    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      addSSL = true;
      locations = {
        "/".proxyPass = "http://127.0.0.1:${config.services.grafana.port}";
        };
    };

    ragon.persist.extraDirectories = [
      "${config.services.grafana.dataDir}"
    ];
  };
}
