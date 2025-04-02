{ config, lib, pkgs, inputs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.cli;
in
{
  options.ragon.cli.enable = lib.mkEnableOption "Enables ragons CLI stuff";
  options.ragon.cli.maximal = mkBoolOpt true;
  config = lib.mkIf cfg.enable {
    security.sudo.extraConfig = "Defaults lecture = never";
    # root shell
    users.extraUsers.root.shell = pkgs.zsh;

  };
}
