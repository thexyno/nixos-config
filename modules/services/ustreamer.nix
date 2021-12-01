{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ustreamer;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.ustreamer.enable = lib.mkEnableOption "Enables ustreamer Server";
  options.ragon.services.ustreamer.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "octoprint-stream";
    };
  options.ragon.services.ustreamer.device =
    lib.mkOption {
      type = lib.types.str;
      default = "/dev/video0";
    };
  options.ragon.services.ustreamer.resolution =
    lib.mkOption {
      type = lib.types.str;
      default = "1280x720";
    };
  options.ragon.services.ustreamer.framerate =
    lib.mkOption {
      type = lib.types.str;
      default = "30";
    };
  config = lib.mkIf cfg.enable {
    systemd.services.ustreamer = {
      description = "ustreamer webcam streamer";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        DynamicUser = "yes";
        Group = "video";
        Restart = "on-failure";
        RestartSec = 1;
      };

      script = ''
        exec ${pkgs.ustreamer}/bin/ustreamer \
          --format=mjpeg \\ # Device input format
          --allow-origin=\* \\
          --encoder=hw \\
          --workers=3 \\
          --dv-timings \\ # Use DV-timings
          --drop-same-frames=30 \\ # Save the traffic
          -U /run/ustreamer.sock
          -i ${cfg.device} \\
          -r ${cfg.resolution}
      '';
    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/".proxyPass = "http://unix:/run/ustreamer.sock";
      locations."/stream" = {
        proxyPass = "http://unix:/run/ustreamer.sock";
        extraConfig = ''
          postpone_output 0;
          proxy_buffering off;
          proxy_ignore_headers X-Accel-Buffering; 
        '';
      };
    };
  };
}
