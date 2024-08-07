{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.docker;
in
{
  options.ragon.services.docker.enable = lib.mkEnableOption "Enables docker";
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    ragon.user.extraGroups = [ "docker" "podman" ];
    ragon.persist.extraDirectories = [
      "/var/lib/docker"
      "/var/cache/docker"
    ];
  };
}
