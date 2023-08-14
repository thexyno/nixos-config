{ config, lib, pkgs, ... }:
with lib;
with lib.my;
with builtins;
let
  cfg = config.ragon.services.samba;
  allowedIPs = cfg.allowedIPs;
  cfgExports = cfg.exports;
in
{
  options.ragon.services.samba.enable = mkEnableOption "Enables Samba";
  options.ragon.services.samba.shares = mkOption {
    type = lib.types.attrs;
    default = { };
  };
  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      shares = cfg.shares;
    };
    ragon.persist.extraDirectories = [
      "/var/lib/samba"
    ];

    networking.firewall.allowedTCPPorts = [ 139 445 ];
    networking.firewall.allowedUDPPorts = [ 137 138 ];
  };
}
