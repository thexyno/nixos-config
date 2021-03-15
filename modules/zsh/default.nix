{config, lib, pkgs, ...}:
let
  sourcesnix = import ../../nix/sources.nix;
  inherit (lib) fileContents;
in
{
  enable = true;
  histSize = 10000;
  enableAutosuggestions = true;
  enableCompletion = true;

  interactiveShellInit =
    let
      zshrc = builtins.fileContents ./zshrc;

      sources = [
        "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh"
        "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/globalias/globalias.plugin.zsh"
        "${sourcesnix.zsh-vim-mode}/zsh-vim-mode.plugin.zsh"
        "${sourcesnix.zsh-syntax-highlighting}/zsh-syntax-highlighting.plugin.zsh"
        "${sourcesnix.zsh-completions}/zsh-completions.plugin.zsh"
        "${sourcesnix.agkozak-zsh-prompt}/agkozak-zsh-prompt.plugin.zsh"
      ];

      source = map (source: "source ${source}") sources;

      plugins = builtins.concatStringsSep "\n" ([
        "${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin"
      ] ++ source);

      in
      ''
        ${plugins}
        ${zshrc}
      '';
}
