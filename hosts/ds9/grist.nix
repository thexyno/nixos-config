{
  pkgs,
  config,
  lib,
  ...
}:
{
  ragon.agenix.secrets.ds9GristEnv = { };
  virtualisation.quadlet = {
    containers.grist = {
      containerConfig = {
        image = "docker.io/gristlabs/grist-oss";
        networks = [
          "podman"
          "db-net"
        ];
        volumes = [
          "grist:/persist"
        ];
        environments = {
          GRIST_SANDBOX_FLAVOR = "gvisor";
          APP_HOME_URL = "https://grist.hailsatan.eu";
          GRIST_FORCE_LOGIN = "true";
          GRIST_TELEMETRY_LEVEL = "off";
          GRIST_ALLOW_AUTOMATIC_VERSION_CHECKING = "false";
        };
        addCapabilities = [ "SYS_PTRACE" ];
        environmentFiles = [
          config.age.secrets.ds9GristEnv.path
        ];
      };
    };
  };
}
