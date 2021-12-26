{ pkgs, inputs, lib, ... }:
with lib;
with lib.my;
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  imports = [
    "${inputs.home-manager}/nix-darwin"
  ];

  home-manager.sharedModules  = [{
    imports = mapModulesRec' ../../hm-modules (x: x);
    programs.home-manager.enable = true;
    home.stateVersion = "21.11";
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      vimAlias = true;
      viAlias = true;
      configure = inputs.self.nixosConfigurations.enterprise.config.programs.neovim.configure;
    };
  }];

  # nvim
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
    direnv # needed for lorri
    unzip
    my.pridecat
    pv
    killall
    pciutils
    youtube-dl
    aria2
    tmux
    libqalculate
    python3 # ultisnips
    lazygit
    nodejs
    # inputs.rnix-lsp.packages."${pkgs.system}".rnix-lsp
    shfmt
    shellcheck
    vim-vint
    nodePackages.write-good
    ctags
  ];
  environment.etc."nvim".source = ./config;
  # zsh
  programs.zsh = {
    enable = true;
    promptInit = inputs.self.nixosConfigurations.enterprise.config.programs.zsh.promptInit;
    variables = inputs.self.nixosConfigurations.enterprise.config.programs.zsh.promptInit;
  };
  environment.shellAliases = inputs.self.nixosConfigurations.enterprise.config.environment.shellAliases;
  environment.variables = inputs.self.nixosConfigurations.enterprise.config.environment.variables;

  

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;
}
