{ config, pkgs, lib, ... }:
let
  cfg = config.ragon.services.caddy;
in
{
  options.ragon.services.caddy.enable = lib.mkEnableOption "enables the caddy webserver";
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = import ./custom-caddy.nix { inherit lib; pkgs = pkgs.unstable; };
    };
    ragon.persist.extraDirectories = [ config.services.caddy.dataDir ];
  };
}
