{ config, lib, inputs, pkgs, ... }:
let
  cfg = config.ragon.nvim;
in
with lib;
{
  options.ragon.nvim.enable = lib.mkEnableOption "Enables ragons nvim config";
  options.ragon.nvim.maximal = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "enable coc.nvim and other heavy plugins";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    ] ++ optionals cfg.maximal [
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

    ragon.user.persistent.extraDirectories = [
      ".local/share/nvim"

    ] ++ optionals cfg.maximal [
      ".config/TabNine"
      ".local/share/TabNine"
      ".config/coc"
    ];

    programs.neovim = {
      package = if cfg.maximal then pkgs.neovim-nightly else inputs.nixpkgs.legacyPackages."${pkgs.system}".neovim;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
      enable = true;
      configure =
        let
          nnn-vim = pkgs.vimUtils.buildVimPlugin {
            name = "nnn-vim";
            src = inputs.nnn-vim;
          };
          coc--nvim = pkgs.vimUtils.buildVimPlugin {
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
        {
          packages.myVimPackage.start = with pkgs.vimPlugins; [
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
          ] ++ optionals cfg.maximal [
            undotree
            vim-pandoc
            vim-pandoc-live-preview
            vim-pandoc-syntax
            ultisnips
            coc--nvim
            dart-vim
          ];
          customRC = ''
            set runtimepath^=/etc/nvim
            lua dofile('/etc/nvim/init.lua')
          '';
        };
    };

    environment.etc."nvim".source = ./config;


  };
}
