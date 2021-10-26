{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.cli.scripts;
in
with lib;
with lib.my;
{
  options.ragon.cli.scripts.enable = mkBoolOpt true;
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.my.scripts ];
  };
}
