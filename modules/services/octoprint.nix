{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.octoprint;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.octoprint.enable = lib.mkEnableOption "Enables the Octoprint Server";
  options.ragon.services.octoprint.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "octoprint";
    };
  config = lib.mkIf cfg.enable {
    services.octoprint = {
      host = "127.0.0.1";
      enable = true;
      extraConfig = lib.mkMerge [
        {
          appearance = {
            name = config.networking.hostName;
            color = "orange";
          };
          webcam = {
            ffmpeg = "${pkgs.ffmpeg}/bin/ffmpeg";
            watermark = false;
          };
        }
        (lib.mkIf (config.ragon.services.ustreamer.enable) {
          webcam = {
            stream = "https://${config.ragon.services.ustreamer.domainPrefix}.${domain}/stream";
            snapshot = "https://${config.ragon.services.ustreamer.domainPrefix}.${domain}/snapshot";
          };
        })
      ];
    };
    ragon.persist.extraDirectories = [
      "${config.services.octoprint.stateDir}"
    ];
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/".proxyWebsockets = true;
      locations."/".proxyPass = "http://${config.services.octoprint.host}:${toString config.services.octoprint.port}";
    };
  };
}
