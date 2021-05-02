{  config, lib, pkgs, inputs, ... }:
let
  cfg = config.ragon.cli;
  ragon = config.ragon;
in
{
  options.ragon.cli.enable = lib.mkEnableOption "Enables ragons CLI stuff";
  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    ragon.nvim.enable = true;


    security.sudo.extraConfig = "Defaults lecture = never";

    # firewall
    # networking.firewall.enable = true;
    # networking.firewall.allowPing = true;

    # root shell
    users.extraUsers.root.shell = pkgs.zsh;

    environment.shellAliases = {
      v = "nvim";
      vim = "nvim";
      gpl = "git pull";
      gp = "git push";
      gc = "git commit -v";
      kb = "git commit -m \"\$(curl -s http://whatthecommit.com/index.txt)\"";
      gs = "git status -v";
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
      unzip
      nnn
      bat
      htop
      exa
      curl
      fd
      file
      fzf
      git
      libqalculate
      neofetch
      ripgrep
      pv
      killall
      pciutils
    ];

  };

}