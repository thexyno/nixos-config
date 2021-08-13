{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.mullvad;
in
{
  options.ragon.services.mullvad.enable = lib.mkEnableOption "Enables the mullvad Client service";
  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/113589#issuecomment-893233499
    networking.firewall.checkReversePath = "loose";
    networking.wireguard.enable = true;
    services.mullvad-vpn.enable = true;
    environment.systemPackages = [ pkgs.mullvad-vpn ];
  };
}
