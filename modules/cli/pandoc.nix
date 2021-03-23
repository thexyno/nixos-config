{ config, lib, pkgs, ...}:
let
  sources = import ../../nix/sources.nix;
  cfg = config.ragon.cli.pandoc;
in
{
  options.ragon.cli.pandoc.enable = lib.mkEnableOption "Enables Ragons Pandoc Configuration";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pandoc
      pandoc-plantuml-filter
      texlive.combined.scheme-full
      zathura
    ];

  };


}
