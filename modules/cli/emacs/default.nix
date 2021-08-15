{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.cli.emacs;
in
{
  options.ragon.cli.emacs.enable = lib.mkEnableOption "Enables ragons emacs congfig (WIP)";
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.emacs.overlay ];
    services.emacs.enable = true;
    services.emacs.package = pkgs.emacsGcc;
    environment.systemPackages = with pkgs; [
      emacsGcc
      git
      ripgrep
      # optional dependencies
      coreutils # basic GNU utilities
      fd
      clang
    ];
    ragon.user.persistent.extraDirectories = [
      ".emacs.d"
    ];
      
  };
}
