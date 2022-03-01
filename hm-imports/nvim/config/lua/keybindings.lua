local map = require('utils').map

-- split binds
map { 'n', '<A-h>', ':vertical resize -5<CR>', noremap = true, silent = true}
map { 'n', '<A-l>', ':vertical resize +5<CR>', noremap = true, silent = true}
map { 'n', '<A-j>', ':resize -5<CR>', noremap = true, silent = true}
map { 'n', '<A-k>', ':resize +5<CR>', noremap = true, silent = true}
map { 'n', '<A-=>', '<C-w> =', noremap = true, silent = true}

map { 'n', '<A-s>', ':vsp<CR>', noremap = true, silent = true}
map { 'n', '<C-s>', ':split<CR>', noremap = true, silent = true}

map { 'n', '<C-h>', '<C-w>h', noremap = true, silent = true}
map { 'n', '<C-j>', '<C-w>j', noremap = true, silent = true}
map { 'n', '<C-k>', '<C-w>k', noremap = true, silent = true}
map { 'n', '<C-l>', '<C-w>l', noremap = true, silent = true}

-- buffer binds
map { 'n', ',q', ':bd<CR>', noremap = false, silent = true}
map { 'n', ',b', ':Buffers<CR>', noremap = false, silent = true}
-- tab binds
map { 'n', '<C-t>', ':tabnew<CR>', noremap = false, silent = true}

-- copy paste
map { 'v', '<C-c>', '"+y', noremap = true, silent = true}
map { 'n', '<C-b>', '"+P', noremap = false, silent = true}
map { 'n', '<C-p>', ':registers<CR>', noremap = true, silent = true}

-- sudo :w
map { 'c', 'w!!', 'w !sudo tee > /dev/null %', noremap = false, silent = false}


-- terminal
map { 'n', '<leader>t', ':term<CR>', noremap = false, silent = true}
map { 't', '<C-b>', '<C-\\><C-n>', noremap = true, silent = true}

-- plugins - commentary
map { 'n', '<leader>c', ':Commentary<CR>', noremap = false, silent = true}
-- plugins - vista
map { 'n', '<leader>v', ':Vista!!<CR>', noremap = false, silent = true}
-- plugins - nnn
map { 'n', '<tab>', '::NnnPicker %:p:h<CR>', noremap = true, silent = true}

-- plugins - terminal
map {"n", "<leader>l", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true}}
