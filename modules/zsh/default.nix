{config, lib, pkgs, ...}:
let
  sourcesnix = import ../../nix/sources.nix;
  inherit (lib) fileContents;
in
{
  enable = true;
  histSize = 10000;
  autosuggestions.enable = true;
  enableCompletion = true;

  promptInit =
    let
      zshrc = builtins.readFile ./zshrc;

      sources = [
        "${sourcesnix.agkozak-zsh-prompt}/agkozak-zsh-prompt.plugin.zsh"
        "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh"
        "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/globalias/globalias.plugin.zsh"
        "${sourcesnix.zsh-vim-mode}/zsh-vim-mode.plugin.zsh"
        "${sourcesnix.zsh-syntax-highlighting}/zsh-syntax-highlighting.plugin.zsh"
        "${sourcesnix.zsh-completions}/zsh-completions.plugin.zsh"
      ];

      source = map (x: "source " + x) sources;

      plugins = builtins.concatStringsSep "\n" (source);

      in
      ''
        ${zshrc}
        ${plugins}
      '';
}
