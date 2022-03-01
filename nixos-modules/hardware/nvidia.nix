{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.nvidia;
in
{
  options.ragon.hardware.nvidia.enable = lib.mkEnableOption "Enables nvidia stuff (why didnt i buy amd?)";
  config = lib.mkIf cfg.enable {
    # nivea
    services.xserver.videoDrivers = [ "nvidia" ];

  };
}
