{ config, lib, pkgs, ...}:
let
  cfg = config.ragon.nvim;
  sources = import ../nix/sources.nix;
in
{
  options.ragon.nvim.enable = lib.mkEnableOption "Enables ragons nvim config";
  options.ragon.nvim.maximal = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "enable coc.nvim and other heavy plugins"
  };
  config = lib.mkIf cfg.enable {
  environment.systemPackages = with pkgs; [
    nnn
    (neovim.override {
      vimAlias = true;
      viAlias = true;
      configure =
        let
          nnn-vim = pkgs.vimUtils.buildVimPlugin {
            name = "nnn-vim";
            src = sources.nnn-vim;
          };
          coc-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "coc-nvim";
            src = sources.coc-nvim;
          };
        in
        {
        customRC = (builtins.readFile ./nvim/init.vim);
        plug.plugins = with pkgs.vimPlugins // sources; [
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
          vim-devicons
        ] // lib.mkIf cfg.maximal [
          vim-pandoc
          vim-pandoc-syntax
          ultisnips
          coc-nvim
        ];
    }; 
    })
  ] // lib.mkIf cfg.maximal [
    nodejs
    (import sources.rnix-lsp)
  ];
    
  environment.etc."nvim/coc-settings.json".text = (builtins.readFile ./nvim/coc-settings.json);
  environment.etc."nvim/coc-settings.json".enable = cfg.maximal;


  };
}
