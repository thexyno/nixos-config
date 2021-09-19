{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = importTOML ../../data/prometheus.toml;
  hostName = config.networking.hostName;
in
{
  config = mkMerge ([
    (mkIf (cfg.master.hostname == hostName) {
      services.prometheus = {
        enable = true;
        port = cfg.master.port;
        scrapeConfigs = traceValSeq (foldl (a: b: a ++ b) [] (map (x: (map (y: {
          job_name = "${x}_${y}";
          static_configs = [
            {
              targets = [
                ''${
                  if (y == hostName)
                  then "127.0.0.1"
                  else (
                    if (builtins.elem y (builtins.attrNames cfg.hostOverrides))
                    then cfg.hostOverrides.${y}
                    else "${y}.hailsatan.eu"
                  )
                }:${toString cfg.exporters.${x}.port}''
              ];
            }
          ];
        }) cfg.exporters.${x}.hosts )) (builtins.attrNames cfg.exporters)));
      };
      ragon.persist.extraDirectories = [
        "/usr/lib/${config.services.prometheus.stateDir}"
      ];
    })
      {
        # some global settings
        services.prometheus.exporters.node.enabledCollectors = [ "systemd" ];
      }
    ] ++
    (map (x: {
      services.prometheus.exporters.${x} = {
        enable = (builtins.elem hostName cfg.exporters.${x}.hosts);
        port = cfg.exporters.${x}.port;
        openFirewall = true;
        firewallFilter = "-p tmp -s ${cfg.master.ip} -m tcp --dport ${toString cfg.exporters.${x}.port}";
      };
      } ) (builtins.attrNames cfg.exporters))
      );

}

