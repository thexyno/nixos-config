{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.prometheus;
in
{
  options.ragon.prometheus = {
    enable = lib.mkEnableOption "Enable prometheus monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };

      scrapeConfigs = [
        {
          job_name = "${networking.hostName}_node";
          staticConfigs = [
            {
              targets = [ "127.0.0.1:${toString config.sercies.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];
    };
  };
}

