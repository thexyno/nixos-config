{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.vmhost;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.vmhost.enable = lib.mkEnableOption "Enables libvirt and stuff";
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
    };
    ragon.persist.extraDirectories = [
      "/var/lib/libvirt"
    ];
  };
}
