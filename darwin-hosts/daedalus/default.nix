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
  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
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
            vim-tmux-navigator
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
      yt-dlp
      aria2
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

      #tectonic
      pandoc

      yabai

      google-cloud-sdk
    ];

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      history = 10000;
      plugins = with pkgs.tmuxPlugins [
        vim-tmux-navigator
        cpu
      ];
        extraConfig = ''
        set -g status-right '#{ram_bg_color} RAM: #{ram_icon} #{ram_percentage} #{cpu_bg_color} CPU: #{cpu_icon} #{cpu_percentage} | %F %H:%M:%S'
        ## COLORSCHEME: gruvbox dark (medium)
        set-option -g status "on"
        
        # default statusbar color
        set-option -g status-style bg=colour237,fg=colour223 # bg=bg1, fg=fg1
        
        # default window title colors
        set-window-option -g window-status-style bg=colour214,fg=colour237 # bg=yellow, fg=bg1
        
        # default window with an activity alert
        set-window-option -g window-status-activity-style bg=colour237,fg=colour248 # bg=bg1, fg=fg3
        
        # active window title colors
        set-window-option -g window-status-current-style bg=red,fg=colour237 # fg=bg1
        
        # pane border
        set-option -g pane-active-border-style fg=colour250 #fg2
        set-option -g pane-border-style fg=colour237 #bg1
        
        # message infos
        set-option -g message-style bg=colour239,fg=colour223 # bg=bg2, fg=fg1
        
        # writing commands inactive
        set-option -g message-command-style bg=colour239,fg=colour223 # bg=fg3, fg=bg1
        
        # pane number display
        set-option -g display-panes-active-colour colour250 #fg2
        set-option -g display-panes-colour colour237 #bg1
        
        # clock
        set-window-option -g clock-mode-colour colour109 #blue
        
        # bell
        set-window-option -g window-status-bell-style bg=colour167,fg=colour235 # bg=red, fg=bg
        
        ## Theme settings mixed with colors (unfortunately, but there is no cleaner way)
        set-option -g status-justify "left"
        set-option -g status-left-style none
        set-option -g status-left-length "80"
        set-option -g status-right-style none
        set-option -g status-right-length "80"
        set-window-option -g window-status-separator ""
        
        set-option -g status-left "#[bg=colour241,fg=colour248] #S #[bg=colour237,fg=colour241,nobold,noitalics,nounderscore]"
        set-option -g status-right "#[bg=colour237,fg=colour239 nobold, nounderscore, noitalics]#[bg=colour239,fg=colour246] %Y-%m-%d  %H:%M #[bg=colour239,fg=colour248,nobold,noitalics,nounderscore]#[bg=colour248,fg=colour237] #h "
        
        set-window-option -g window-status-current-format "#[bg=colour214,fg=colour237,nobold,noitalics,nounderscore]#[bg=colour214,fg=colour239] #I #[bg=colour214,fg=colour239,bold] #W#{?window_zoomed_flag,*Z,} #[bg=colour237,fg=colour214,nobold,noitalics,nounderscore]"
        set-window-option -g window-status-format "#[bg=colour239,fg=colour237,noitalics]#[bg=colour239,fg=colour223] #I #[bg=colour239,fg=colour223] #W #[bg=colour237,fg=colour239,noitalics]"
      '';
    };

    #    programs.kitty = {
    #      enable = true;
    #      theme = "Gruvbox Dark Hard";
    #      settings = {
    #        font_family = "JetBrainsMono NF";
    #        font_size = "12.0";
    #      };
    #
    #    };

    home.activation = {
      aliasApplications =
        let
          apps = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = config.home.packages;
            pathsToLink = "/Applications";
          };
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Install MacOS applications to the user environment.
          HM_APPS="$HOME/Applications/Home Manager Apps"

          # Reset current state
          [ -e "$HM_APPS" ] && $DRY_RUN_CMD rm -r "$HM_APPS"
          $DRY_RUN_CMD mkdir -p "$HM_APPS"

          # .app dirs need to be actual directories for Finder to detect them as Apps.
          # The files inside them can be symlinks though.
          $DRY_RUN_CMD cp --recursive --symbolic-link --no-preserve=mode -H ${apps}/Applications/* "$HM_APPS"
          # Modes need to be stripped because otherwise the dirs wouldn't have +w,
          # preventing us from deleting them again
          # In the env of Apps we build, the .apps are symlinks. We pass all of them as
          # arguments to cp and make it dereference those using -H
        '';
    };

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
