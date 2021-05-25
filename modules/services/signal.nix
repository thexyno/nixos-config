{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.signal;
in
{
  options.ragon.services.signal.enable = lib.mkEnableOption "Enables signal-cli-rest-api";
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers."signal-cli-rest-api" = {
      image = "bbernhard/signal-cli-rest-api";
      volumes = [
        "/var/lib/signal:/home/.local/share/signal-cli"
      ];
    };
    ragon.persist.extraDirectories = [
      "/var/lib/signal"
    ];
  };
}
