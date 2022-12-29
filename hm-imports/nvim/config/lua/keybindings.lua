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
map { 'n', '<leader>q', ':bd<CR>', noremap = false, silent = true}
-- telescope
map { 'n', '<leader>fb', '<cmd>Telescope buffers<CR>', noremap = false, silent = true}
map { 'n', '<leader>ff', '<cmd>Telescope find_files<CR>', noremap = false, silent = true}
map { 'n', '<leader>fs', '<cmd>Telescope live_grep<CR>', noremap = false, silent = true}
map { 'n', '<leader>fr', '<cmd>Telescope registers<CR>', noremap = false, silent = true}
map { 'n', '<leader>pp', '<cmd>lua require\'telescope\'.extensions.projects.projects{}<cr>', noremap = false, silent = true}
-- tab binds
map { 'n', '<C-t>', ':tabnew<CR>', noremap = false, silent = true}

-- copy paste
map { 'v', '<C-c>', '"+y', noremap = true, silent = true}
map { 'n', '<C-b>', '"+P', noremap = false, silent = true}

-- sudo :w
map { 'c', 'w!!', 'w !sudo tee > /dev/null %', noremap = false, silent = false}


-- terminal
-- map { 'n', '<leader>t', ':term<CR>', noremap = false, silent = true}
-- map { 't', '<C-b>', '<C-\\><C-n>', noremap = true, silent = true}

-- plugins - commentary
map { 'n', '<leader>c', ':Commentary<CR>', noremap = false, silent = true}
-- plugins - vista
map { 'n', '<leader>v', ':Vista!!<CR>', noremap = false, silent = true}
-- plugins - nnn
map { 'n', '<tab>', '::NnnPicker %:p:h<CR>', noremap = true, silent = true}

-- plugins - terminal
map {"n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true}}
map {"n", "<leader>gp", "<cmd>lua _pipeline_toggle()<CR>", {noremap = true, silent = true}}
