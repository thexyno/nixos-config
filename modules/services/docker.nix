{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.docker;
in
{
  options.ragon.services.docker.enable = lib.mkEnableOption "Enables docker";
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    ragon.user.extraGroups = [ "docker" ];
  };
}
