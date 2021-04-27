{  config, lib, pkgs, inputs, ... }:
let
  cfg = config.ragon.common-cli;
  ragon = config.ragon;
in
{
  options.ragon.common-cli.enable = lib.mkEnableOption "Enables ragons common CLI stuff";
  config = lib.mkIf cfg.enable {
    # TODO move this somwhere else
    # Set passwords
    users.users.root.initialHashedPassword =  config.age.secrets.rootpasswd.path;
    users.users.ragon.initialHashedPassword = config.age.secrets.ragonpasswd.path;

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
    ragon.nvim.enable = true;
    console.font = "Lat2-Terminus16";
    console.keyMap = "de";

    # openssh
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;

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
