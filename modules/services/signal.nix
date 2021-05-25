{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.signal;
in
{
  options.ragon.services.signal.enable = lib.mkEnableOption "Enables signal-cli-rest-api";
  options.ragon.services.signal.port = 
    lib.mkOption {
      type = lib.types.uint;
      default = 54321;
    };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers."signal-cli-rest-api" = {
      image = "bbernhard/signal-cli-rest-api";
      ports = [
        "8080:54321"
      ];
      volumes = [
        "/var/lib/signal:/home/.local/share/signal-cli"
      ];
    };
    ragon.persist.extraDirectories = [
      "/var/lib/signal"
    ];
  };
}
