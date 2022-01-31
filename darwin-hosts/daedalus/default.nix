{ pkgs, inputs, lib, ... }:
with lib;
with lib.my;
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  imports = [
    "${inputs.home-manager}/nix-darwin"
  ];

  users.users.ragon = {
    name = "ragon";
    home = "/Users/ragon";
  };
  programs.gnupg.agent.enable = true;
  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.ragon = { pkgs, lib, inputs, ... }: {
    imports = mapModulesRec' ../../hm-modules (x: x);
    programs.home-manager.enable = true;
    home.stateVersion = "21.11";

    programs.neovim =
      let
        conf = inputs.self.nixosConfigurations.enterprise.config.programs.neovim.configure;
      in
      {
        enable = true;
        package = pkgs.neovim-nightly;
        vimAlias = true;
        viAlias = true;
        extraConfig = conf.customRC;
        plugins =
          let
            nnn-vim = pkgs.vimUtils.buildVimPlugin {
              name = "nnn-vim";
              src = inputs.nnn-vim;
            };
            coc-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "coc-nvim";
              src = inputs.coc-nvim;
            };
            dart-vim = pkgs.vimUtils.buildVimPlugin {
              name = "dart-vim";
              src = inputs.dart-vim;
            };
            vim-pandoc-live-preview = pkgs.vimUtils.buildVimPlugin {
              name = "vim-pandoc-live-preview";
              src = inputs.vim-pandoc-live-preview;
            };
            orgmode-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "orgmode-nvim";
              src = inputs.orgmode-nvim;
              dontBuild = true;
            };
          in
          map (x: { plugin = x; }) (with pkgs.vimPlugins; [
            galaxyline-nvim
            nvim-web-devicons
            nnn-vim
            rainbow
            vista-vim
            polyglot
            vim-commentary
            vim-table-mode
            vim-speeddating
            vim-nix
            gruvbox
            incsearch-vim
            vim-highlightedyank
            vim-fugitive
            fzf-vim
            fzfWrapper
            vim-devicons
            toggleterm-nvim
            undotree
            vim-pandoc
            vim-pandoc-live-preview
            vim-pandoc-syntax
            ultisnips
            coc-nvim
            dart-vim
          ]);
      };


    home.shellAliases = inputs.self.nixosConfigurations.enterprise.config.environment.shellAliases;
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PATH = "$PATH:$HOME/development/flutter/bin:/Applications/Android Studio.app/Contents/bin/:/Applications/Docker.app/Contents/Resources/bin:/Applications/Android Studio.app/Contents/jre/Contents/Home/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/system/sw/bin";
      JAVA_HOME = "/Applications/Android Studio.app/Contents/jre/Contents/Home/";
    };
    programs.zsh = {
      enable = true;
      enableSyntaxHighlighting = true;
      initExtra = inputs.self.nixosConfigurations.enterprise.config.programs.zsh.promptInit;
    };
    home.packages = with pkgs; [
      nnn
      bat
      htop
      exa
      curl
      fd
      file
      lorri
      fzf
      git
      neofetch
      ripgrep
      direnv # needed for lorri
      unzip
      my.pridecat
      my.scripts
      pv
      killall
      pciutils
      lefthook
      youtube-dl
      aria2
      tmux
      libqalculate


      terraform-ls
      terraform

      python3 # ultisnips
      lazygit
      nodejs
      #inputs.rnix-lsp.packages."${pkgs.system}".rnix-lsp
      shfmt
      shellcheck
      jq
      vim-vint
      nodePackages.write-good
      ctags

      tectonic
      pandoc

      yabai

      google-cloud-sdk
    ];

  };

  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 4;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = 1;
    dock.autohide = true;
    dock.mru-spaces = false;
    dock.show-recents = false;
    dock.static-only = true;
    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;
    loginwindow.GuestEnabled = false;
  };

  environment.pathsToLink = [ "/share/zsh" ]; # zsh completions
  # nvim
  environment.etc."nvim".source = ../../modules/cli/nvim/config;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;
  nix.buildCores = 0; # use all cores
  nix.maxJobs = 10; # use all cores
}
