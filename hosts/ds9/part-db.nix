{ pkgs, config, lib, inputs, ... }:
{
  ragon.agenix.secrets.ds9PartDbEnv = { };
  virtualisation.quadlet =
    {
      containers = {
        partdb-server.containerConfig.image = "jbtronics/part-db1";
        partdb-server.containerConfig.networks = [
          "db-net"
          "podman"
        ];
        partdb-server.containerConfig.volumes = [
          "partdb-uploads:/var/www/html/uploads"
          "partdb-media:/var/www/html/public/media"
        ];
        partdb-server.containerConfig.environments = {
          APP_ENV = "docker";
          DEFAULT_LANG = "en";
          DEFAULT_TIMEZONE = "Europe/Berlin";
          BASE_CURRENCY = "EUR";
          INSTANCE_NAME = "xynos_hoard";
          TRUSTED_PROXIES = "10.88.0.0/16";
          DEFAULT_URI = "https://hoard.hailsatan.eu/";
        };
        partdb-server.serviceConfig.TimeoutStartSec = "60";
        partdb-server.containerConfig.environmentFiles = [
          config.age.secrets.ds9PartDbEnv.path
        ];
      };
    };
}
