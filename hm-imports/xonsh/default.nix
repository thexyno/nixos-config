{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.xonsh;
in
{
  options.ragon.xonsh.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xonsh
    ];
  };
}
