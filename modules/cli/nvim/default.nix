{ config, lib, inputs, pkgs, ... }:
let
  cfg = config.ragon.nvim;
in
{
  options.ragon.nvim.enable = lib.mkEnableOption "Enables ragons nvim config";
  options.ragon.nvim.maximal = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "enable coc.nvim and other heavy plugins";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nnn
      #  ] // lib.mkIf cfg.maximal [ python3 # ultisnips
      nodejs
      #(import inputs.rnix-lsp)
    ];
    ragon.user.persistent.extraDirectories = [
      ".config/coc"
      ".local/share/nvim"
      ".config/TabNine"

    ];

    programs.neovim = {
      package = pkgs.neovim-nightly.override {
        configure.customRC = (builtins.readFile ./init.vim);

      };
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
        in
        {
          plug.plugins = with pkgs.vimPlugins; [
            nnn-vim
            vista-vim
            undotree
            polyglot
            rainbow
            vim-commentary
            vim-table-mode
            vim-speeddating
            vim-nix
            gruvbox
            incsearch-vim
            vim-highlightedyank
            vim-fugitive
            lightline-vim
            fzf-vim
            fzfWrapper
            vim-devicons
            #        ] // lib.mkIf cfg.maximal [
            vim-pandoc
            vim-pandoc-live-preview
            vim-pandoc-syntax
            ultisnips
            coc-nvim
            dart-vim
          ];
        };
    };

    environment.etc."nvim/coc-settings.json".text = (builtins.readFile ./coc-settings.json);
    environment.etc."nvim/coc-settings.json".enable = cfg.maximal;
    environment.etc."nvim/completion".source = ./completion;


  };
}
