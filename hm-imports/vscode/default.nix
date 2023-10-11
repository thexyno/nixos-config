{ pkgs, config, lib, ... }:
let
  cfg = config.ragon.vscode;
in
{
  options.ragon.vscode.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim # vim mode (hopefully good)
        yzhang.markdown-all-in-one # markdown
        jdinhlife.gruvbox # theme
      ];
    };
  };
}
