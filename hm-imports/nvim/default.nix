{pkgs, config, inputs, ...}:
{
    home.packages = with pkgs;[
      python3 # ultisnips
      lazygit
      nodejs
      inputs.rnix-lsp.packages."${pkgs.system}".rnix-lsp
      shfmt
      shellcheck
      vim-vint
      nodePackages.write-good
      ctags
    ];
    home.file.".config/nvim".source = ./config;
    programs.neovim =
      let
        conf = inputs.self.nixosConfigurations.enterprise.config.programs.neovim.configure;
      in
      {
        enable = true;
        package = pkgs.neovim-nightly;
        vimAlias = true;
        viAlias = true;
        extraConfig = ''
            set runtimepath^=~/.config/nvim
            lua dofile('~/.config/nvim/init.lua')
        '';
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
            lualine-nvim
            fzfWrapper
            vim-devicons
            toggleterm-nvim
            undotree
            vim-pandoc
            vim-pandoc-syntax
            ultisnips
            coc-nvim
            dart-vim
          ]);
      };
}
