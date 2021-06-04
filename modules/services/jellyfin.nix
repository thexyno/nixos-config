{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.jellyfin;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.jellyfin.enable = lib.mkEnableOption "Enables jellyfin";
  options.ragon.services.jellyfin.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "j";
    };
  config = lib.mkIf cfg.enable {
    services.jellyfin.enable = true;
    services.jellyfin.openFirewall = true;
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      useACMEHost = "${domain}";
      addSSL = true;
      locations = {
        "/" = {

          proxyPass = "http://127.0.0.1:8096";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;

            # Disable buffering when the nginx proxy gets very resource heavy upon streaming
            proxy_buffering off;
          '';
        };
        "/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };
      };

    };
    ragon.persist.extraDirectories = [
      "/var/cache/jellyfin"
      "/var/lib/jellyfin"
    ];
  };
}
