{ config, lib, pkgs, ... }:
with lib;
with lib.my;
with builtins;
let
  cfg = config.ragon.services.nfs;
  allowedIPs = cfg.allowedIPs;
  cfgExports = cfg.exports;
in
{
  options.ragon.services.nfs.enable = mkEnableOption "Enables NFS";
  options.ragon.services.nfs.allowedIPs = mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "10.0.0.9" "10.40.0.10" ]; # todo filter allowedIPs list by dhcp statics
  };
  options.ragon.services.nfs.exports = mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "/data" ];
  };
  config = mkIf cfg.enable {

    services.nfs.server = {
      enable = true;
      exports =
        let
          genIP = ip: "${ip}(rw,fsid=0,no_subtree_check)";
          allAllowed = concatStringsSep " " (map genIP allowedIPs);
        in
        concatStringsSep "\n" (map (x: "${x} ${allAllowed}") cfgExports);





    };

    networking.firewall.allowedTCPPorts = [ 2049 ];
  };
}
