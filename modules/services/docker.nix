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
    ragon.user.extraGroups = [ "docker" "podman" ];
    ragon.user.persistent.extraDirectories = [ ".local/share/containers" ".cache/containers" ];
    ragon.persist.extraDirectories = [ "/var/lib/containers" ];
    virtualisation.containers.storage.settings.storage = {
      driver = "zfs";
      mount_program = "${pkgs.zfs}/bin/mount.zfs";
      options.zfs.fsname = "pool/containers";
    };
  };
}
