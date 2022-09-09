{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.unifi;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.unifi.enable = lib.mkEnableOption "Enables the unifi console";
  options.ragon.services.unifi.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "unifi";
    };
  config = lib.mkIf cfg.enable {
    services.unifi = {
      enable = true;
      openFirewall = true;
    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/".proxyPass = "https://127.0.0.1:8443";
      locations."/".proxyWebsockets = true;
    };
    ragon.persist.extraDirectories = [
      "/var/lib/unifi"
    ];
  };
}
