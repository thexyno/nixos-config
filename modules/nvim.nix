{ config, lib, pkgs, ...}:
let
  cfg = config.ragon.nvim;
  sources = import ../nix/sources.nix;
in
{
  options.ragon.nvim.enable = lib.mkEnableOption "Enables ragons nvim config";
  config = lib.mkIf cfg.enable {
  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      viAlias = true;
      customRC = (builtins.readFile ./nvim/init.vim);
      configure = {
        plug.plugins = with pkgs.vimPlugins; [
          sources.nnn-vim
          vista-vim
          undotree
          polyglot
          rainbow
          vim-commentary
          vim-table-mode
          vim-pandoc
          vim-pandoc-syntax
          vim-speeddating
          vim-nix
          gruvbox
          ultisnips
          incsearch-vim
          vim-highlightedyank
          vim-fugitive
          lightline-vim
          fzf-vim
          vim-devicons
          sources.coc-nvim
        ];
    }; 
    })
  ];
    
  environment.etc."nvim/coc-settings.json".text = (builtins.readFile ./nvim/coc-settings.json);


  };
}




