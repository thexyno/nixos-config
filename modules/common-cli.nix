{ config, lib, pkgs, ...}:
let
  cfg = config.ragon.common-cli;
in
{
  options.ragon.common-cli.enable = lib.mkEnableOption "Enables ragons common CLI stuff";

  config = lib.mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_DK.UTF-8";
    };
     programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    console.font = "Lat2-Terminus16";
    console.keyMap = "de";

    # openssh
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;

    # firewall
    networking.firewall.enable = true;
    networking.firewall.allowPing = true;

    # root shell
    users.extraUsers.root.shell = pkgs.zsh;

    # programs 
    programs = {
      # import zsh config
      zsh = (import ./zsh/default.nix { config = config; lib = lib; pkgs = pkgs;  });
      fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
          "--inline-info"
        ];
      };
    };
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
      ripgrep
      pv
    ];

  }

}
