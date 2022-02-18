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

      #tectonic
      pandoc

      yabai

      google-cloud-sdk
    ];
    programs.alacritty = {
      enable = true;
      settings = {
        key_bindings = [
          { key = "A"; mods = "Option"; chars = "\\x1ba"; } # Alt settings ref = "https://github.com/alacritty/alacritty/issues/62#issuecomment-347552058
          { key = "B"; mods = "Option"; chars = "\\x1bb"; }
          { key = "C"; mods = "Option"; chars = "\\x1bc"; }
          { key = "D"; mods = "Option"; chars = "\\x1bd"; }
          { key = "E"; mods = "Option"; chars = "\\x1be"; }
          { key = "F"; mods = "Option"; chars = "\\x1bf"; }
          { key = "G"; mods = "Option"; chars = "\\x1bg"; }
          { key = "H"; mods = "Option"; chars = "\\x1bh"; }
          { key = "I"; mods = "Option"; chars = "\\x1bi"; }
          { key = "J"; mods = "Option"; chars = "\\x1bj"; }
          { key = "K"; mods = "Option"; chars = "\\x1bk"; }
          { key = "L"; mods = "Option"; chars = "\\x1bl"; }
          { key = "M"; mods = "Option"; chars = "\\x1bm"; }
          { key = "N"; mods = "Option"; chars = "\\x1bn"; }
          { key = "O"; mods = "Option"; chars = "\\x1bo"; }
          { key = "P"; mods = "Option"; chars = "\\x1bp"; }
          { key = "Q"; mods = "Option"; chars = "\\x1bq"; }
          { key = "R"; mods = "Option"; chars = "\\x1br"; }
          { key = "S"; mods = "Option"; chars = "\\x1bs"; }
          { key = "T"; mods = "Option"; chars = "\\x1bt"; }
          { key = "U"; mods = "Option"; chars = "\\x1bu"; }
          { key = "V"; mods = "Option"; chars = "\\x1bv"; }
          { key = "W"; mods = "Option"; chars = "\\x1bw"; }
          { key = "X"; mods = "Option"; chars = "\\x1bx"; }
          { key = "Y"; mods = "Option"; chars = "\\x1by"; }
          { key = "Z"; mods = "Option"; chars = "\\x1bz"; }
          { key = "A"; mods = "Option|Shift"; chars = "\\x1bA"; }
          { key = "B"; mods = "Option|Shift"; chars = "\\x1bB"; }
          { key = "C"; mods = "Option|Shift"; chars = "\\x1bC"; }
          { key = "D"; mods = "Option|Shift"; chars = "\\x1bD"; }
          { key = "E"; mods = "Option|Shift"; chars = "\\x1bE"; }
          { key = "F"; mods = "Option|Shift"; chars = "\\x1bF"; }
          { key = "G"; mods = "Option|Shift"; chars = "\\x1bG"; }
          { key = "H"; mods = "Option|Shift"; chars = "\\x1bH"; }
          { key = "I"; mods = "Option|Shift"; chars = "\\x1bI"; }
          { key = "J"; mods = "Option|Shift"; chars = "\\x1bJ"; }
          { key = "K"; mods = "Option|Shift"; chars = "\\x1bK"; }
          { key = "L"; mods = "Option|Shift"; chars = "\\x1bL"; }
          { key = "M"; mods = "Option|Shift"; chars = "\\x1bM"; }
          { key = "N"; mods = "Option|Shift"; chars = "\\x1bN"; }
          { key = "O"; mods = "Option|Shift"; chars = "\\x1bO"; }
          { key = "P"; mods = "Option|Shift"; chars = "\\x1bP"; }
          { key = "Q"; mods = "Option|Shift"; chars = "\\x1bQ"; }
          { key = "R"; mods = "Option|Shift"; chars = "\\x1bR"; }
          { key = "S"; mods = "Option|Shift"; chars = "\\x1bS"; }
          { key = "T"; mods = "Option|Shift"; chars = "\\x1bT"; }
          { key = "U"; mods = "Option|Shift"; chars = "\\x1bU"; }
          { key = "V"; mods = "Option|Shift"; chars = "\\x1bV"; }
          { key = "W"; mods = "Option|Shift"; chars = "\\x1bW"; }
          { key = "X"; mods = "Option|Shift"; chars = "\\x1bX"; }
          { key = "Y"; mods = "Option|Shift"; chars = "\\x1bY"; }
          { key = "Z"; mods = "Option|Shift"; chars = "\\x1bZ"; }
          { key = "Key1"; mods = "Option"; chars = "\\x1b1"; }
          { key = "Key2"; mods = "Option"; chars = "\\x1b2"; }
          { key = "Key3"; mods = "Option"; chars = "\\x1b3"; }
          { key = "Key4"; mods = "Option"; chars = "\\x1b4"; }
          { key = "Key5"; mods = "Option"; chars = "\\x1b5"; }
          { key = "Key6"; mods = "Option"; chars = "\\x1b6"; }
          { key = "Key7"; mods = "Option"; chars = "\\x1b7"; }
          { key = "Key8"; mods = "Option"; chars = "\\x1b8"; }
          { key = "Key9"; mods = "Option"; chars = "\\x1b9"; }
          { key = "Key0"; mods = "Option"; chars = "\\x1b0"; }
          { key = "Space"; mods = "Control"; chars = "\\x00"; } # Ctrl + Space
          { key = "Grave"; mods = "Option"; chars = "\\x1b`"; } # Alt + `
          { key = "Grave"; mods = "Option|Shift"; chars = "\\x1b~"; } # Alt + ~
          { key = "Period"; mods = "Option"; chars = "\\x1b."; } # Alt + .
          { key = "Key8"; mods = "Option|Shift"; chars = "\\x1b*"; } # Alt + *
          { key = "Key3"; mods = "Option|Shift"; chars = "\\x1b#"; } # Alt + #
          { key = "Period"; mods = "Option|Shift"; chars = "\\x1b>"; } # Alt + >
          { key = "Comma"; mods = "Option|Shift"; chars = "\\x1b<"; } # Alt + <
          { key = "Minus"; mods = "Option|Shift"; chars = "\\x1b_"; } # Alt + _
          { key = "Key5"; mods = "Option|Shift"; chars = "\\x1b%"; } # Alt + %
          { key = "Key6"; mods = "Option|Shift"; chars = "\\x1b^"; } # Alt + ^
          { key = "Backslash"; mods = "Option"; chars = "\\x1b\\\\"; } # Alt + \
          { key = "Backslash"; mods = "Option|Shift"; chars = "\\x1b|"; } # Alt + |
        ];
        env.TERM = "xterm-256color";
        alt_send_esc = true;
        scrolling.multiplier = 1;
        font.normal.family = "JetBrainsMono Nerd Font";
        font.size = 12;
        colors = {
          background = "#282828";
          foreground = "#EBDBB2";
          normal = {
            black = "0x282828";
            red = "0xcc241d";
            green = "0x98971a";
            yellow = "0xd79921";
            blue = "0x458588";
            magenta = "0xb16286";
            cyan = "0x689d6a";
            white = "0xa89984";
          };

          bright = {
            black = "0x928374";
            red = "0xfb4934";
            green = "0xb8bb26";
            yellow = "0xfabd2f";
            blue = "0x83a598";
            magenta = "0xd3869b";
            cyan = "0x8ec07c";
            white = "0xebdbb2";
          };
        };
      };
    };

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
