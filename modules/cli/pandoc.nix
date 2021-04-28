{ config, lib, pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
  cfg = config.ragon.cli.pandoc;
in
{
  options.ragon.cli.pandoc.enable = lib.mkEnableOption "Enables Ragons Pandoc Configuration";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pandoc
      packages.pandocode
      pandoc-plantuml-filter
      haskellPackages.pandoc-include-code
      texlive.combined.scheme-full
      zathura
    ];

  };
}
