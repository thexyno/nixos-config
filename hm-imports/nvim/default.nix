{ pkgs, config, lib, inputs, ... }:
{
  home.packages = with pkgs;[
    # telescope
    ripgrep
    # embedded terminal
    lazygit
    glab

    # language servers
    nil # nix
    #inputs.rnix-lsp.packages."${pkgs.system}".rnix-lsp
    gopls # go
    pyright # python3
    terraform-ls
    terraform
    nodePackages.typescript
    nodePackages.typescript-language-server
    sumneko-lua-language-server
    ltex-ls # languageTool
    nodePackages.vscode-langservers-extracted # eslint, ...
    texlab # latex
    tectonic
    # rust completion
    cargo
    rustc
    rustfmt
    rust-analyzer


    # other stuff
    neovim-remote
  ];
  home.file.".config/nvim".source = ./config;
  home.file.".config/nvim".recursive = true;
  programs.neovim =
    {
      enable = true;
      package = pkgs.neovim-nightly;
      extraConfig = ''
        set runtimepath^=~/.config/nvim
        lua dofile('${./config/nvim.lua}')
      '';
      vimAlias = true;
      viAlias = true;
      plugins =
        let
          nnn-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "nnn-nvim";
            version = "1.0.0";
            src = inputs.nnn-nvim;
          };
          notify-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "notify-nvim";
            version = "1.0.0";
            src = inputs.notify-nvim;
          };
          noice-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "noice-nvim";
            version = "1.0.0";
            src = inputs.noice-nvim;
          };
        in
        map (x: { plugin = x; }) (with pkgs.vimPlugins; [
          vim-tmux-navigator # tmux
          nnn-nvim # nnn as filebrowser
          gruvbox-material # theme
          # complete ui overhaul
          notify-nvim
          nui-nvim
          noice-nvim
          telescope-nvim
          telescope-ui-select-nvim
          # line
          lualine-nvim

          # vcs integration
          gitsigns-nvim

          # completion
          nvim-lspconfig # lsp
          vimspector # dap
          pkgs.unstable.vimPlugins.rust-tools-nvim # rust special sauce
          # completion - nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          nvim-cmp # completion ui
          lspkind-nvim # icons for completion
          # completion-snippets
          luasnip
          cmp_luasnip


          toggleterm-nvim # embed terminals (for lazygit,...)

          # treesitter
          (nvim-treesitter.withPlugins (
            plugins: pkgs.tree-sitter.allGrammars
          ))
        ]);
    };
}
