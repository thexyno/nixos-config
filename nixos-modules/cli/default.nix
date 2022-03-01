{ config, lib, pkgs, inputs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.cli;
  ragon = config.ragon;
in
{
  options.ragon.cli.enable = lib.mkEnableOption "Enables ragons CLI stuff";
  options.ragon.cli.maximal = mkBoolOpt true;
  config = lib.mkIf cfg.enable {
    security.sudo.extraConfig = "Defaults lecture = never";
    # root shell
    users.extraUsers.root.shell = pkgs.zsh;

    environment.shellAliases = {
      v = "nvim";
      vim = "nvim";
      gpl = "git pull";
      gp = "git push";
      lg = "lazygit";
      gc = "git commit -v";
      kb = "git commit -m \"\$(curl -s http://whatthecommit.com/index.txt)\"";
      gs = "git status -v";
      gfc = "git fetch && git checkout";
      gl = "git log --graph";
      l = "exa -la --git";
      la = "exa -la --git";
      ls = "exa";
      ll = "exa -l --git";
      cat = "bat";
    };
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    environment.systemPackages = with pkgs; [
      nnn
      bat
      htop
      exa
      curl
      fd
      file
      fzf
      git
      neofetch
      tmux
      ripgrep
      pv
      direnv # needed for lorri
      unzip
      tmux
      aria2
      yt-dlp
      neovim
    ];

  };

}
