{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.cli;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra =
      let
        zshrc = builtins.readFile ./zshrc;
        p10k = builtins.readFile ./p10k.zsh;

        sources = [
          "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
          #  "${inputs.agkozak-zsh-prompt}/agkozak-zsh-prompt.plugin.zsh"
          "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh"
          "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/globalias/globalias.plugin.zsh"
          "${inputs.zsh-vim-mode}/zsh-vim-mode.plugin.zsh"
          "${inputs.zsh-syntax-highlighting}/zsh-syntax-highlighting.plugin.zsh"
          "${inputs.zsh-completions}/zsh-completions.plugin.zsh"
        ];

        source = map (x: "source " + x) sources;

        plugins = builtins.concatStringsSep "\n" (source);

      in
      ''
        ${p10k}
        ${zshrc}
        ${plugins}
      '';
  };

}
