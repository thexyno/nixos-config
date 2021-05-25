{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.nginx;
in
{
  options.ragon.services.nginx.enable = lib.mkEnableOption "Enables nginx";
  options.ragon.services.nginx.domain = 
    lib.mkOption {
      type = lib.types.str;
      default = "hailsatan.eu";
    };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recomendedProxySettings = true;
      recomendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
  };
}
