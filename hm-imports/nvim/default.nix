{ pkgs, config, lib, inputs, ... }:
{
  home.packages = with pkgs;[
    # telescope
    ripgrep
    # embedded terminal
    lazygit
    glab
    gh

    # language servers
    nil # nix
    #inputs.rnix-lsp.packages."${pkgs.system}".rnix-lsp
    gopls # go
    pyright # python3
    terraform-ls
    terraform
    nodePackages.typescript
    nodePackages.typescript-language-server
    haskell-language-server
    sumneko-lua-language-server
    ltex-ls # languageTool
    nodePackages.vscode-langservers-extracted # eslint, ...
    texlab # latex
    tectonic
    # rust completion
    cargo
    rustc
    rustfmt
    unstable.rust-analyzer
    # c# debugging
    (pkgs.writeShellScriptBin "netcoredbg" ''exec ${pkgs.unstable.netcoredbg}/bin/netcoredbg "$@"'') # don't fill $path with dlls

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
          gruvbox-nvim # theme
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
          nvim-dap # dap
          nvim-dap-ui # dap stuffzies
          nvim-dap-go
          pkgs.unstable.vimPlugins.rust-tools-nvim # rust special sauce
          pkgs.unstable.vimPlugins.flutter-tools-nvim
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
          friendly-snippets # some premade snippets


          toggleterm-nvim # embed terminals (for lazygit,...)

          # treesitter
          (nvim-treesitter.withPlugins (
            plugins: pkgs.tree-sitter.allGrammars
          ))
        ]);
    };
}
