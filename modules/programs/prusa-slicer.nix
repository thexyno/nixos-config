{ inputs, config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.programs.prusa-slicer;
in
{
  options.ragon.gui.gnome.enable = mkEnableOption "Enables Prusa Slicer";
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      prusa-slicer
    ];
    ragon.user.persistent.extraDirectories = [
      ".config/PrusaSlicer"
    ];
  };
}
