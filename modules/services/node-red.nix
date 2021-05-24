{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.node-red;
  tz = time.timeZone;
  domain = config.ragon.nginx.domain;
in
{
  options.ragon.services.node-red.enable = lib.mkEnableOption "Enables node-red";
  options.ragon.services.node-red.domainPrefix = 
    lib.mkOption {
      type = lib.types.str;
      default = "nr";
    };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-contaiers.containers."node-red" = {
      image = "nodered/node-red";
      volumes = [
        "/var/lib/node-red:/data"
      ];
      # ports = [
      #   "1880:1880"
      # ];
      environment = {
        TZ = tz;
      };

    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      locations."/".proxyPass = "http://node-red:1880";
    };
    persist.extraDirectories = [
      "/var/lib/node-red"
    ];
  };
}
