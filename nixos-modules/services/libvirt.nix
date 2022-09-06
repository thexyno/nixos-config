{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.libvirt;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.libvirt.enable = lib.mkEnableOption "Enables libvirt and stuff";
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
    };
    ragon.user.extraGroups = [ "kvm" "libvirtd" ];
    security.polkit.enable = true;
    ragon.persist.extraDirectories = [
      "/var/lib/libvirt"
    ];
  };
}
