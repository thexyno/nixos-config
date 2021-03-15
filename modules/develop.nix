{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.develop;
in
{
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    imports = [
      ./develop/flutter.nix
    ];
  };
}

