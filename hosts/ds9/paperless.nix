{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  virtualisation.quadlet = {
    containers = {
      paperless-server.containerConfig.image = "ghcr.io/paperless-ngx/paperless-ngx:latest";

      paperless-server.containerConfig.networks = [
        "podman"
        "db-net"
        "paperless-net"
      ];
      paperless-server.containerConfig.volumes = [
        "paperless-media:/usr/src/paperless/media"
        "paperless-data:/usr/src/paperless/data"
        "/data/paperless-export:/usr/src/paperless/export"
        "/data/paperless-consume:/usr/src/paperless/consume"
      ];
      paperless-server.containerConfig.environments = {
        PAPERLESS_REDIS = "redis://paperless-redis:6379";
        PAPERLESS_DBHOST = "postgres";
        PAPERLESS_TIKA_ENABLED = "1";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-gotenberg:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://paperless-tika:9998";
        USERMAP_UID = "1000";
        USERMAP_GID = "100";
        PAPERLESS_URL = "https://paperless.hailsatan.eu";
        PAPERLESS_TIME_ZONE = "Europe/Berlin";
        PAPERLESS_OCR_LANGUAGE = "deu";
        PAPERLESS_TRUSTED_PROXIES = "10.89.0.1";
        PAPERLESS_ENABLE_HTTP_REMOTE_USER = "true";
        PAPERLESS_ENABLE_HTTP_REMOTE_API = "true";
        PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "HTTP_X_AUTHENTIK_USERNAME";
        PAPERLESS_DISABLE_REGULAR_LOGIN = "true";

      };
      paperless-server.serviceConfig.TimeoutStartSec = "60";
      paperless-redis.containerConfig.image = "docker.io/library/redis:alpine";
      paperless-redis.containerConfig.networks = [
        "paperless-net"
      ];
      paperless-redis.containerConfig.volumes = [ "paperless-redis:/data" ];
      paperless-redis.serviceConfig.TimeoutStartSec = "60";
      paperless-gotenberg = {
        containerConfig = {
          image = "docker.io/gotenberg/gotenberg:8.7";
          exec = "gotenberg --chromium-disable-javascript=true --chromium-allow-list=file:///tmp/.*";
          networks = [
            "paperless-net"
          ];
        };
        serviceConfig.TimeoutStartSec = "60";
      };
      paperless-tika = {
        containerConfig = {
          image = "docker.io/apache/tika:latest";
          networks = [
            "paperless-net"
          ];
        };
        serviceConfig.TimeoutStartSec = "60";
      };
    };
    networks = {
      paperless.networkConfig.ipv6 = true;
      paperless.networkConfig.name = "paperless-net";
      paperless.networkConfig.internal = true;
    };
  };
}
