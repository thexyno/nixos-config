{ config, inputs, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.paperless;
  domain = config.ragon.services.nginx.domain;
in
{
  imports = [ ../../tmp/pap.nix ];
  options.ragon.services.paperless.enable = mkEnableOption "Enables paperless ng";
  options.ragon.services.paperless.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "paperless";
    };
  config = mkIf cfg.enable {
    services.paperless-ng = {
      enable = true;
      mediaDir = mkDefault "/data/documents/paperless";
      consumptionDir = mkDefault "/data/applications/paperless-consumption";
      consumptionDirIsPublic = true;
      passwordFile = "/run/secrets/paperlessAdminPW";
      extraConfig = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
      };
    };
    ragon.agenix.secrets.paperlessAdminPW = { user = "${config.services.paperless-ng.user}"; mode = "0440"; };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      addSSL = true;
      locations."/".proxyPass = "http://${config.services.paperless-ng.address}:${toString config.services.paperless-ng.port}";
      locations."/".proxyWebsockets = true;
  };
  ragon.persist.extraDirectories = [
    "${config.services.paperless-ng.dataDir}"
  ];
};
}
