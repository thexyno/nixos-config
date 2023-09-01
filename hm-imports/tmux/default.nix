{ config, pkgs, ... }: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 10000;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
    extraConfig = ''
      set -sg escape-time 0 # makes vim esc usable
      new-session -s main
      bind-key -n C-e send-prefix
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      set-option -g default-terminal "tmux-256color"
      set -as terminal-overrides ',xterm*:Tc:sitm=\E[3m'
      run-shell -b '~/.config/tmux-switch-colors/start_theme_switcher.sh'
    '';
  };
  home.file.".config/tmux-switch-colors".source = ./tmux-switch-colors;
}
