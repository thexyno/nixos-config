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
  options.ragon.services.cfg.enable = mkEnableOption "Enables NFS";
  options.ragon.services.cfg.allowedIPs = mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ]; # todo filter allowedIPs list by dhcp statics
    };
  options.ragon.services.cfg.exports = mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/media/data" ];
    };
  config = mkIf cfg.enable {

    services.nfs.server = {
      enable = true;
      exports = 
      let
        genIP = ip: "${ip}(rw,fsid=0)";
        allAllowed = concatStringsSep " " (map genIP allowedIPs);
      in
      concatStringsSep "\n" (map (x: "${x} ${allAllowed}") exports);





    };

    networking.firewall.allowedTCPPorts = [ 2049 ];
  };
}
