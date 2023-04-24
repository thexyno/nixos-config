-- general settings
vim.cmd [[
  filetype plugin on
  filetype indent plugin on
  filetype plugin indent on
  syntax on
]]
-- mapleader
local opt = vim.opt
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- color stuff
opt.termguicolors = true -- 24bit color
require('gruvbox').setup({})
opt.background = 'dark' -- dark gruvbox
vim.cmd ':colorscheme gruvbox'
--vimspector
vim.g.vimspector_base_dir = vim.env.HOME .. "/.local/share/nvim/vimspector"
vim.g.vimspector_enable_mappings = "HUMAN"


opt.encoding = 'utf-8'
opt.number = true
opt.relativenumber = true
opt.undofile = true               -- save undo chages even after computer restart
opt.showcmd = true                -- show (partial) command in status line
opt.showmatch = true              -- show match brackets
opt.wildmenu = true               -- visual autocomplete for command menu
-- Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
opt.splitbelow = true
opt.splitright = true
-- indents
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
-- buffers don't get unloaded when hidden
opt.hidden = true
-- low updatetime so it isnt as slow
opt.updatetime = 100

require('utils')
require('keybindings')
require('filetypes')

-- load plugin luas (idk how to do that autmagically)
require('plugin.treesitter')
require('plugin.nnn')
require('plugin.terminal')
require('plugin.noice')
require('plugin.telescope')
require('plugin.cmp')
require('plugin.lsp')
require('plugin.dap')
require('plugin.lualine')
require('plugin.gitsigns')
