{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = importTOML ../../data/monitoring.toml;
  hostName = config.networking.hostName;
  getHost = (y:
    if (y == hostName)
    then "127.0.0.1"
    else
      (
        if (builtins.elem y (builtins.attrNames cfg.hostOverrides))
        then cfg.hostOverrides.${y}
        else y
      )
  );
in
{
  config = mkMerge ([
    (mkIf (cfg.master.hostname == hostName) {
      services.loki.enable = true;
      services.loki.configFile = pkgs.writeText "loki.yml" ''
        auth_enabled: false
        server:
          http_listen_port: 3100
          grpc_listen_port: 9096
        
        common:
          ring:
            instance_addr: 127.0.0.1
            kvstore:
              store: inmemory
          replication_factor: 1
          path_prefix: /tmp/loki
        
        schema_config:
          configs:
          - from: 2020-05-15
            store: boltdb-shipper
            object_store: filesystem
            schema: v11
            index:
              prefix: index_
              period: 24h

        ruler:
          alertmanager_url: http://localhost:9093
        analytics:
          reporting_enabled: false
      '';
      services.prometheus = {
        enable = true;
        scrapeConfigs = foldl (a: b: a ++ b) [ ] (map
          (x: (map
            (y: {
              job_name = "${x}_${y}";
              static_configs = [
                {
                  targets = [
                    ''${getHost y}:${toString config.services.prometheus.exporters.${x}.port}''
                  ];
                }
              ];
            })
            cfg.exporters.${x}.hosts))
          (builtins.attrNames cfg.exporters));
      };
      ragon.persist.extraDirectories = [
        "/var/lib/${config.services.prometheus.stateDir}"
        "${config.services.loki.dataDir}"
      ];
    })
    {
      # some global settings
      services.prometheus.exporters.node.enabledCollectors = [ "systemd" ];
      services.prometheus.exporters.smokeping.hosts = [ "1.1.1.1" ];
    }
    (mkIf (builtins.elem hostName cfg.promtail.hosts) {
      systemd.services.promtail.serviceConfig.SupplementaryGroups = lib.optional config.services.nginx.enable [ "nginx" ];
      systemd.services.promtail.serviceConfig.ReadWritePaths = [ "/var/log/nginx" ];
      services.promtail = {
        enable = true;
        configuration = {
          server.http_listen_port = 28183;
          positions.filename = "/tmp/positions.yaml";
          clients = [{ url = "http://${cfg.master.ip}:3100/loki/api/v1/push"; }];
          scrape_configs = [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  host = hostName;
                };
              };
              relabel_configs = [{
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }];
            }
          ] ++ lib.optionals config.services.nginx.enable [
            {
              job_name = "nginx";
              static_configs = [
                {
                  targets = [ "localhost" ];
                  labels = {
                    job = "nginx";
                    __path__ = "/var/log/nginx/access.log";
                    host = hostName;
                  };
                }
              ];
              pipeline_stages = [
                {
                  regex = {
                    expression = ''(?P<remote_addr>.+) - - \[(?P<time_local>.+)\] "(?P<method>.+) (?P<url>.+) (HTTP\/(?P<version>\d.\d))" (?P<status>\d{3}) (?P<body_bytes_sent>\d+) (["](?P<http_referer>(\-)|(.+))["]) (["](?P<http_user_agent>.+)["])'';
                  };
                }
                {
                  labels = {
                    remote_addr = null;
                    time_local = null;
                    method = null;
                    url = null;
                    status = null;
                    body_bytes_sent = null;
                    http_referer = null;
                    http_user_agent = null;
                  };
                }
                {
                  timestamp = {
                    source = "time_local";
                    format = "02/Jan/2006:15:04:05 -0700";
                  };
                }
              ];
            }
          ];
        };
      };

    })
  ] ++
  (map
    (x: {
      services.prometheus.exporters.${x} = {
        enable = (builtins.elem hostName cfg.exporters.${x}.hosts);
        #openFirewall = (hostName != cfg.master.hostname);
        #firewallFilter = if (hostName != cfg.master.hostname) then "-p tcp -s ${cfg.master.ip} -m tcp --dport ${toString config.services.prometheus.exporters.${x}.port}" else null;
      };
    })
    (builtins.attrNames cfg.exporters))
  );

}

