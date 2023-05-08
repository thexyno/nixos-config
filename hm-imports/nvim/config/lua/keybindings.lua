local map = require('utils').map

-- split binds
map { 'n', '<A-h>', '<cmd>vertical resize -5<CR>', noremap = true, silent = true}
map { 'n', '<A-l>', '<cmd>vertical resize +5<CR>', noremap = true, silent = true}
map { 'n', '<A-j>', '<cmd>resize -5<CR>', noremap = true, silent = true}
map { 'n', '<A-k>', '<cmd>resize +5<CR>', noremap = true, silent = true}
map { 'n', '<A-=>', '<C-w> =', noremap = true, silent = true}

map { 'n', '<A-s>', '<cmd>vsp<CR>', noremap = true, silent = true}
map { 'n', '<C-s>', '<cmd>split<CR>', noremap = true, silent = true}

map { 'n', '<C-h>', '<C-w>h', noremap = true, silent = true}
map { 'n', '<C-j>', '<C-w>j', noremap = true, silent = true}
map { 'n', '<C-k>', '<C-w>k', noremap = true, silent = true}
map { 'n', '<C-l>', '<C-w>l', noremap = true, silent = true}

-- telescope
map { 'n', '<leader>b', '<cmd>Telescope buffers<CR>', noremap = false, silent = true}
--map { 'n', '<leader>ff', '<cmd>Telescope find_files<CR>', noremap = false, silent = true}
map { 'n', '<leader>s', '<cmd>Telescope live_grep<CR>', noremap = false, silent = true}
map { 'n', '<C-p>', '<cmd>Telescope registers<CR>', noremap = false, silent = true}
--map { 'n', '<leader>pp', '<cmd>lua require\'telescope\'.extensions.projects.projects{}<cr>', noremap = false, silent = true}
-- tab binds
map { 'n', '<C-t>', '<cmd>tabnew<CR>', noremap = false, silent = true}
map { 'n', '<C-Left>', '<cmd>tabprevious<CR>', noremap = false, silent = true}
map { 'n', '<C-Right>', '<cmd>tabnext<CR>', noremap = false, silent = true}

-- copy paste
map { 'v', '<C-c>', '"+y', noremap = true, silent = true}
--map { 'n', '<C-b>', '"+P', noremap = false, silent = true}

-- sudo :w
map { 'c', 'w!!', 'w !sudo tee > /dev/null %', noremap = false, silent = false}

-- vimspector
map { 'n', '<leader>di', '<Plug>VimspectorBalloonEval', noremap = false, silent = false }
map { 'x', '<leader>di', '<Plug>VimspectorBalloonEval', noremap = false, silent = false }

-- terminal
-- map { 'n', '<leader>t', ':term<CR>', noremap = false, silent = true}
-- map { 't', '<C-b>', '<C-\\><C-n>', noremap = true, silent = true}

-- plugins - nnn
map { 'n', '<tab>', '<cmd>:NnnPicker %:p:h<CR>', noremap = true, silent = true}
map { 'n', '<s-tab>', '<cmd>:NnnExplorer %:p:h<CR>', noremap = true, silent = true}

-- plugins - terminal
map {"n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true}}
map {"n", "<leader>gl", "<cmd>lua _glab_toggle()<CR>", {noremap = true, silent = true}}
map {"n", "<leader>gh", "<cmd>lua _ghub_toggle()<CR>", {noremap = true, silent = true}}

-- diagnostic
map {"n", "<leader>e", "<cmd>lua require\'telescope.builtin\'.lsp_diagnostics{}<CR>", { noremap = true, silent = true}}
map {"n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", { noremap = true, silent = true}}
map {"n", "]g", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true}}
map {"n", "[g", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true}}
-- dap
map {"n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true}}
map {"n", "<leader>du", "<cmd>lua require'dapui'.toggle()<CR>", { noremap = true, silent = true}}
map {"n", "<leader>dc", "<cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true}}
map {"n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>", { noremap = true, silent = true}}
map {"n", "<leader>di", "<cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true}}
-- cp
map {"n", "<leader>c", "<cmd>Copilot panel<CR>", { noremap = true, silent = true}}
vim.cmd [[
  imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
  ]]
