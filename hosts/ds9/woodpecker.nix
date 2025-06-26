{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.podman.dockerSocket.enable = true;
  ragon.agenix.secrets.ds9WoodpeckerEnv = { };
  ragon.agenix.secrets.ds9WoodpeckerAgentSecretEnv = { };
  virtualisation.quadlet = {
    containers = {
      woodpecker-server = {
        containerConfig.image = "woodpeckerci/woodpecker-server:v3";
        containerConfig.volumes = [
          "woodpecker-server-data:/var/lib/woodpecker"
        ];
        containerConfig.networks = [
          "woodpecker-net"
          "podman"
        ];
        containerConfig.environments = {
          WOODPECKER_HOST = "https://woodpecker.hailsatan.eu";
          WOODPECKER_OPEN = "false";
        };
        containerConfig.environmentFiles = [
          config.age.secrets.ds9WoodpeckerEnv.path
          config.age.secrets.ds9WoodpeckerAgentSecretEnv.path
        ];
      };
      woodpecker-agent = {
        containerConfig.environmentFiles = [
          config.age.secrets.ds9WoodpeckerAgentSecretEnv.path
        ];
        containerConfig.image = "woodpeckerci/woodpecker-agent:v3";
        containerConfig.volumes = [
          "woodpecker-agent-config:/etc/woodpecker"
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        containerConfig.environments = {
          WOODPECKER_SERVER = "woodpecker-server:9000";
        };
        containerConfig.networks = [
          "woodpecker-net"
        ];
      };
    };
    networks = {
      woodpecker.networkConfig = {
        ipv6 = true;
        name = "woodpecker-net";
        internal = false;
      };
    };
  };
}
