require('utils')
require('keybindings')
require('filetypes')
local opt = vim.opt

-- load plugin luas (idk how to do that autmagically)
require('plugin.nnn')
require('plugin.rainbow')
require('plugin.terminal')

-- plugins - coc
vim.cmd 'source ~/.config/nvim/coc.vim' -- too lazy to convert all the shit to lua
-- terminal
vim.cmd 'source ~/.config/nvim/terminal.vim' -- too lazy to convert all the shit to lua

-- color stuff
vim.g.gruvbox_italic = 1
vim.cmd ':colorscheme gruvbox'
opt.termguicolors = true -- 24bit color
opt.background = 'dark' -- dark gruvbox

-- general settings
vim.cmd [[
  filetype plugin on
  filetype indent plugin on
  filetype plugin indent on
  syntax on
]]
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
opt.updatetime = 200
require('plugin.lualine')
