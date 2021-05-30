{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.cli.weechat;
in
{
  options.ragon.cli.weechat.enable = lib.mkEnableOption "Enables weeeeeeee";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      weechat
    ];

  };
}
