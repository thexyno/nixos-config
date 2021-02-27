{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nnn fzf ripgrep fd exa
  ];
  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = {
            v = "nvim";
            vim = "nvim";
            gpl = "git pull";
            gp = "git push";
            gc = "git commit -v";
            kb = "git commit -a -m \"\$(curl -s http://whatthecommit.com/index.txt)\"";
            gs = "git status -v";
            gl = "git log --graph";
            l = "exa -la --git";
            la = "exa -la --git";
            ls = "exa";
            ll = "exa -l --git";
    };
  };
  programs.zsh.enable = true;
}

