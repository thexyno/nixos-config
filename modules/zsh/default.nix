{config, lib, pkgs, ...}:
let
  sources = import ../../nix/sources.nix;
in
{
  enable = true;
  histSize = 10000;
  enableAutosuggestions = true;
  enableCompletion = true;

  interactiveShellInit =
    let
      zshrc = builtins.readFile ./zshrc;

      setOptions = [
        "extendedglob"
        "incappendhistory"
        "sharehistory"
        "histignoredups"
        "histfcntllock"
        "histreduceblanks"
        "histignorespace"
        "histallowclobber"
        "autocd"
        "cdablevars"
        "nomultios"
        "pushdignoredups"
        "autocontinue"
        "promptsubst"
      ];

      sources = [
        "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh"
        "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/globalias/globalias.plugin.zsh"
        "${sources.zsh-vim-mode}/zsh-vim-mode.plugin.zsh"
        "${sources.zsh-syntax-highlighting}/zsh-syntax-highlighting.plugin.zsh"
        "${sources.zsh-completions}/zsh-completions.plugin.zsh"
        "${sources.agkozak-zsh-prompt}/agkozak-zsh-prompt.plugin.zsh"
      ];

      source = map (source: "source ${source}") sources;

      plugins = builtins.concatStringsSep "\n" ([
        "${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin"
      ] ++ source);

      in
      ''
        ${plugins}
        ${zshrc}
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        eval $(${pkgs.gitAndTools.hub}/bin/hub alias -s)
        source ${pkgs.skim}/share/skim/key-bindings.zsh
        # needs to remain at bottom so as not to be overwritten
        bindkey jj vi-cmd-mode
      '';
}
