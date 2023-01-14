{ config, pkgs, ... }: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 10000;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      gruvbox
    ];
    extraConfig = ''
      new-session -s main
      bind-key -n C-e send-prefix
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

    '';
  };
}
