{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.docker;
in
{
  options.ragon.services.docker.enable = lib.mkEnableOption "Enables docker";
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    virtualisation.docker.enable = true;
    ragon.user.extraGroups = [ "docker" "podman" ];
    ragon.persist.extraDirectories = [
      "/var/lib/docker"
      "/var/cache/docker"
    ];
  };
}
