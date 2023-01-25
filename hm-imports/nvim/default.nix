{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs;[
    python3 # ultisnips
    lazygit
    nodejs # coc-nvim
    yarn # coc-nvim
    #inputs.rnix-lsp.packages."${pkgs.system}".rnix-lsp
    nil

    # lsp
    shfmt
    shellcheck
    vim-vint
    glab
    nodePackages.write-good
    ctags
  ];
  home.file.".config/nvim".source = ./config;
  home.file.".config/nvim".recursive = true;
  programs.neovim =
    let
      conf = inputs.self.nixosConfigurations.enterprise.config.programs.neovim.configure;
    in
    {
      enable = true;
      #package = pkgs.neovim-nightly;
      extraConfig = ''
        set runtimepath^=~/.config/nvim
        lua dofile('${./config/nvim.lua}')
      '';
      vimAlias = true;
      viAlias = true;
      plugins =
        let
          nnn-vim = pkgs.vimUtils.buildVimPlugin {
            pname = "nnn-vim";
            version = "1.0.0";
            src = inputs.nnn-vim;
          };
          #coc-nvim = pkgs.vimUtils.buildVimPlugin {
          #  name = "coc-nvim";
          #  src = inputs.coc-nvim;
          #};
          #dart-vim = pkgs.vimUtils.buildVimPlugin {
          #  name = "dart-vim";
          #  src = inputs.dart-vim;
          #};
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
          #fzf-vim
          lualine-nvim
          #fzfWrapper
          vim-devicons
          toggleterm-nvim
          undotree
          vim-pandoc
          vim-pandoc-syntax
          ultisnips
          #dart-vim

          plenary-nvim
          telescope-nvim
          project-nvim

          coc-nvim

          #telescope-coc-nvim
          #coc-yank
          coc-yaml
          #coc-wxml
          #coc-vimtex
          #coc-vimlsp
          #coc-vetur # vue
          coc-ultisnips
          coc-tsserver
          #coc-tslint-plugin
          #coc-tslint
          coc-toml
          #coc-texlab
          #coc-tailwindcss
          #coc-tabnine
          #coc-svelte
          #coc-sumneko-lua
          coc-stylelint
          coc-sqlfluff
          #coc-spell-checker
          #coc-solargraph # ruby
          coc-snippets
          #coc-smartf
          coc-sh
          coc-rust-analyzer
          #coc-rls
          #coc-r-lsp
          coc-python
          #coc-pyright
          coc-prettier
          #coc-pairs
          #coc-nginx
          #coc-neco
          #coc-metals
          coc-markdownlint
          coc-lua
          #coc-lists
          coc-json
          coc-jest
          coc-java
          #coc-imselect
          coc-html
          coc-highlight
          #coc-haxe
          coc-go
          #coc-git
          #coc-fzf
          coc-flutter
          #coc-explorer
        ]);
    };
}
