{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.common-cli;
in
{
  config = lib.mkIf cfg.enable {
    ragon.user.persistent = {
      extraDirectories = [
        ".config/zsh"
      ];
    };
    programs.zsh = {
      enable = true;
      histSize = 10000;
      histFile = "$HOME/.config/zsh/history";
      # autosuggestions.enable = true;
      enableCompletion = true;
      setOptions = [
        "HIST_IGNORE_DUPS"
        "SHARE_HISTORY"
        "HIST_FCNTL_LOCK"
        "AUTO_CD"
        "AUTO_MENU"
      ];

      # interactiveShellInit broke agkozak-zsh-prompt for some reaaaaaaaason
      promptInit =
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

  };
}
