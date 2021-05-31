{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.prometheus;
  mode = cfg.mode;
  isMaster = builtins.elem "master" mode;
  isNode = builtins.elem "node" mode;
  domain = cfg.domain;
  hostName = config.networking.hostName;
in
{
  options.ragon.prometheus = {
    enable = lib.mkEnableOption "Enable prometheus monitoring";
    mode = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "master" "node" ]);
      default = [ "node" ];
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "enterprise.hailsatan.eu";
      description = "Domain of the grafana (duh)";
    };
  };

  config = lib.mkIf cfg.enable {
    #    services.prometheus = {
    #      enable = isNode;
    #      port = 9001;
    #      exporters = {
    #        node = {
    #          enable = isNode;
    #          enabledCollectors = [ "systemd" ];
    #          port = 9002;
    #        };
    #      };
    #
    #      scrapeConfigs = [
    #        {
    #          job_name = "${hostName}";
    #          static_configs = [
    #            {
    #              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
    #            }
    #          ];
    #        }
    #      ];
    #    };
    #
    #    services.grafana = {
    #      enable = isMaster;
    #      domain = domain;
    #      port = 2342;
    #      addr = "127.0.0.1";
    #    };
    #
    #    services.promtail = {
    #      enable = isNode;
    #      configuration = {
    #        server = {
    #          http_listen_port = 28183;
    #          grpc_listen_port = 0;
    #        };
    #        positions.filename = "/tmp/positions.yaml";
    #        clients = [{ url = "http://127.0.0.1:3100/loki/api/v1/push"; }];
    #        scrape_configs = [
    #          {
    #            job_name = "journal";
    #            journal = {
    #              max_age = "12h";
    #              labels = {
    #                job = "systemd-journal";
    #                host = "${hostName}";
    #              };
    #            };
    #            relabel_configs = [
    #              {
    #                source_labels = [ "__journal__systemd_unit" ];
    #                target_label = "unit";
    #              }
    #            ];
    #          }
    #        ];
    #      };
    #
    #    };
    #
    #    services.loki = {
    #      enable = isNode;
    #      configuration =
    #        {
    #          auth_enabled = false;
    #
    #          server = {
    #            http_listen_port = 3100;
    #          };
    #
    #          compactor = {
    #            working_directory = "/tmp/loki/boltdb-shipper-compactor";
    #            shared_store = "filesystem";
    #          };
    #
    #          ingester = {
    #            lifecycler = {
    #              address = "0.0.0.0";
    #              ring = {
    #                kvstore = {
    #                  store = "inmemory";
    #                };
    #                replication_factor = 1;
    #              };
    #              final_sleep = "0s";
    #            };
    #            chunk_idle_period = "1h"; # Any chunk not receiving new logs in this time will be flushed
    #            max_chunk_age = "1h"; # All chunks will be flushed when they hit this age, default is 1h
    #            chunk_target_size = 1048576; # Loki will attempt to build chunks up to 1.5MB, flushing first if chunk_idle_period or max_chunk_age is reached first
    #            chunk_retain_period = "30s"; # Must be greater than index read cache TTL if using an index cache (Default index read cache TTL is 5m)
    #            max_transfer_retries = 0; # Chunk transfers disabled
    #          };
    #
    #          schema_config = {
    #            configs = [{
    #              from = "2020-10-24"; # TODO: Should this be "today"?
    #              store = "boltdb-shipper";
    #              object_store = "filesystem";
    #              schema = "v11";
    #              index = {
    #                prefix = "index_";
    #                period = "24h";
    #              };
    #            }];
    #          };
    #
    #          storage_config = {
    #            boltdb_shipper = {
    #              active_index_directory = "/var/lib/loki/boltdb-shipper-active";
    #              cache_location = "/var/lib/loki/boltdb-shipper-cache";
    #              cache_ttl = "24h"; # Can be increased for faster performance over longer query periods, uses more disk space
    #              shared_store = "filesystem";
    #            };
    #            filesystem = {
    #              directory = "/var/lib/loki/chunks";
    #            };
    #          };
    #
    #          limits_config = {
    #            reject_old_samples = true;
    #            reject_old_samples_max_age = "168h";
    #          };
    #
    #          chunk_store_config = {
    #            max_look_back_period = "336h";
    #          };
    #
    #          table_manager = {
    #            retention_deletes_enabled = true;
    #            retention_period = "336h";
    #          };
    #        };
    #    };
    #
    #    # nginx reverse proxy
    #    services.nginx.enable = isMaster;
    #    services.nginx.virtualHosts.${config.services.grafana.domain} = {
    #      locations."/" = {
    #        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
    #        proxyWebsockets = true;
    #      };
    #    };
    #

  };
}

