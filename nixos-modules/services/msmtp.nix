{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.msmtp;
in
{
  options.ragon.services.msmtp.enable = lib.mkEnableOption "Enables msmtp";
  config = lib.mkIf cfg.enable {
    programs.msmtp = {
      enable = true;
    };
    environment.etc."msmtprc".enable = false;
    ragon.agenix.secrets.msmtprc = {
      path = "/etc/msmtprc";
      mode = "0644";
    };
    ragon.agenix.secrets.aliases = {
      path = "/etc/aliases";
      mode = "0644";
    };
  };
}
