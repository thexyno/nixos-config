{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.mullvad;
in
{
  options.ragon.services.mullvad.enable = lib.mkEnableOption "Enables the mullvad Client service";
  config = lib.mkIf cfg.enable {
    # \ragon a bit sparse for now
    services.mullvad-vpn.enable = true;
  };
}
