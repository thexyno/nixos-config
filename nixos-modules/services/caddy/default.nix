{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ragon.services.caddy;
in
{
  options.ragon.services.caddy.enable = lib.mkEnableOption "enables the caddy webserver";
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      # package = import ./custom-caddy.nix { inherit lib; pkgs = pkgs.unstable; };
      package = pkgs.caddy.withPlugins {
        hash = "sha256-Vts9yFfwXxN1A291uoYg9CjYGsLsvygZIldqdlavxeI=";
        plugins = [
          "github.com/caddy-dns/desec@v1.0.1"
        ];
      };
    };
    ragon.persist.extraDirectories = [ config.services.caddy.dataDir ];
  };
}
