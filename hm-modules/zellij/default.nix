{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.zellij;
in
{
  options.ragon.zellij.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
   };  
  };
}
