{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.quadlet = {
    containers = {
      mautrix-signal = {
        containerConfig.image = "dock.mau.dev/mautrix/signal:latest";
        containerConfig.volumes = [
          "mautrix-signal:/data"
        ];
        # containerConfig.publishPorts = [
        #   "100.83.96.25:29328:29328"
        # ];
        containerConfig.networks = [
          "podman"
          "db-net"
        ];
      };
    };
  };
}
