{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = builtins.importTOML ../../data/prometheus.toml;
  hostName = config.networking.hostName;
in
{
  config = traceValSeq ( mkMerge [
    (mkIf (cfg.master.hostaname == hostName) {
      services.prometheus = {
        enable = true;
        port = 9001;
      };
      ragon.persist.extraDirectories = [
        "/usr/lib/${config.services.prometheus.stateDir}"
      ];
    })
      map (x: {
        services.prometheus.exporters.${x}.enable = builtins.elem hostName cfg.exporters.${x}.hosts;
        services.prometheus.exporters.${x}.port = cfg.exporters.${x}.port;
        services.prometheus.exporters.${x}.openFirewall = true;
        services.prometheus.exporters.${x}.firewallFilter = "-p tmp -s ${cfg.master.ip} -m tcp --dport ${toString cfg.exporters.${x}.port}";
      } ) (builtins.attrNames cfg.exporters)
      ({
        # some global settings
        services.prometheus.exporters.node.enabledCollectors = [ "systemd" ];
      })
  ]);
}

