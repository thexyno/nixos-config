{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.grocy;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.grocy.enable = lib.mkEnableOption "Enables grocy and barcodebuddy";
  options.ragon.services.grocy.BBdomainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "barcodebuddy";
    };
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
    virtualisation.oci-containers.containers."barcode-buddy" = {
      volumes = [
        "/var/lib/barcodebuddy:/config"
      ];
      ports = [
        "127.0.0.1:8093:80"
      ];
      image = "f0rc3/barcodebuddy-docker";
      environment = {
        BBUDDY_EXTERNAL_GROCY_URL="${cfg.domainPrefix}.${domain}";
        TZ = config.time.timeZone;
      };
    };
    services.nginx.virtualHosts."${cfg.BBdomainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:8093";
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
      "/var/lib/barcodebuddy"
    ];
  };
}
