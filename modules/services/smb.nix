{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.smb;
in
{
  options.ragon.services.smb.enable = lib.mkEnableOption "Enables samba";
  config = lib.mkIf cfg.enable {
    services.

    networking.firewall.allowedTCPPorts = [ 445 139 ];
    networking.firewall.allowedUDPPorts = [ 137 138 ];
  };
}
