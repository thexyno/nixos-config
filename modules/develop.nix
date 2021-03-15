{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.develop;
in
{
  options.ragon.develop.enable = lib.mkEnableOption "Enables ragons development stuff";
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    imports = [
      ./develop/flutter.nix
    ];
  };
}

