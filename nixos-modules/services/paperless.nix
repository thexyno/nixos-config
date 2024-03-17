{ config, inputs, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.paperless;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.paperless.enable = mkEnableOption "Enables paperless ng";
  options.ragon.services.paperless.location =
    lib.mkOption {
      type = lib.types.str;
      default = "http://${config.services.paperless.address}:${toString config.services.paperless.port}";
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
    ragon.persist.extraDirectories = [
      "${config.services.paperless.dataDir}"
    ];
  };
}
