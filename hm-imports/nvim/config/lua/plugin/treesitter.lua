local treesitter_parser_install_dir = '/var/tmp/nvim-treesitter/parser'
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  --  use_languagetree = true,
  },
  parser_install_dir = treesitter_parser_install_dir,
  -- indent = {
  --   enable = true,
  -- },
  -- autotag = {
  --   enable = true,
  -- },
  -- context_commentstring = {
  --   enable = true,
  --   enable_autocmd = false,
  -- },
  -- refactor = {
  --   highlight_definitions = { enable = true },
  --   highlight_current_scope = { enable = false },
  -- },
}
