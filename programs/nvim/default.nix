{ pkgs,... }:

{
        plug.plugins = with pkgs.vimPlugins // pkgs.callPackage ./custom-plugins.nix { pkgs = pkgs; }; [
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
	customRC = (builtins.readFile ./init.vim);
}
