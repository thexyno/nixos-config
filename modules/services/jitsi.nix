{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.jitsi;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.jitsi.enable = mkEnableOption "Enables jitsi";
  options.ragon.services.jitsi.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "jitsi";
    };
  config = mkIf cfg.enable {
    services.jitsi-meet = {
      enable = true;
      hostName = "${cfg.domainPrefix}.${domain}";
      config = {
        enableWelcomePage = false;
        prejoinPageEnabled = false;
        defaultLanguage = "de";
        startWithVideoMuted = true;
        desktopSharingFrameRate = {
          min = 5;
          max = 30;
        };
        toolbarButtons = [
          "camera"
          "chat"
          "closedcaptions"
          "desktop"
          "download"
          "filmstrip"
          "fullscreen"
          "hangup"
          "microphone"
          "mute-everyone"
          "mute-video-everyone"
          "participants-pane"
          "profile"
          "raisehand"
          "select-background"
          "settings"
          "shareaudio"
          "sharedvideo"
          "shortcuts"
          "stats"
          "tileview"
          "toggle-camera"
          "videoquality"
          "__end"
        ];


      };
      interfaceConfig = {
        SHOW_JITSI_WATERMARK = false;
        SHOW_WATERMARK_FOR_GUESTS = false;
      };
    };
    services.jitsi-videobridge.apis = [ "colibri" "rest" ];
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      enableACME = false;
      useACMEHost = "${domain}";
    };
    services.jitsi-videobridge.openFirewall = true;
  };
}
