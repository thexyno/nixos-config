{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.system.security;
in
{
  options.ragon.system.security = {
    enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    security.sudo.execWheelOnly = true;
    services.openssh = {
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };

  };
}
