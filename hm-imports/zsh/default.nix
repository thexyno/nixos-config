{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.cli;
in
{
    programs.zsh = {
      enable = true;
      histSize = 10000;
      enableCompletion = true;
      initExtra =
        let
          zshrc = builtins.readFile ./zshrc;

          sources = [
            "${inputs.agkozak-zsh-prompt}/agkozak-zsh-prompt.plugin.zsh"
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
          ${zshrc}
          ${plugins}
        '';
    };

}
