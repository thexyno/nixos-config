{ config, lib, pkgs, ...}:
let
  cfg = config.ragon.nvim;
  sources = import ../nix/sources.nix;
in
{
  options.ragon.nvim.enable = lib.mkEnableOption "Enables ragons nvim config";
  config = lib.mkIf cfg.enable {
    programs.nvim = {
      plug.plugins = with pkgs.vimPlugins // sources; [
        nnn-vim
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
        coc-nvim
      ];
      customRC = (builtins.readFile ./nvim/init.vim);
    }
    environment.etc."nvim/coc-settings.json".text = (builtins.readFile ./nvim/coc-settings.json);


  };
}
