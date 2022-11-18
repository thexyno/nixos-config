{ config, inputs, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.paperless;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.paperless.enable = mkEnableOption "Enables paperless ng";
  options.ragon.services.paperless.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "paperless";
    };
  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      mediaDir = mkDefault "/data/documents/paperless";
      consumptionDir = "/data/applications/paperless-consumption";
      consumptionDirIsPublic = true;
      passwordFile = "${config.age.secrets.paperlessAdminPW.path}";
      extraConfig = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_TIME_ZONE = config.time.timeZone;
      };
    };
    ragon.agenix.secrets.paperlessAdminPW = { group = "${config.services.paperless.user}"; mode = "0440"; };
    services.nginx.clientMaxBodySize = "100m";
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      addSSL = true;
      locations."/".proxyPass = "http://${config.services.paperless.address}:${toString config.services.paperless.port}";
      locations."/".proxyWebsockets = true;
    };
    ragon.persist.extraDirectories = [
      "${config.services.paperless.dataDir}"
    ];
  };
}
