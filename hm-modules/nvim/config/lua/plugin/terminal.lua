require('toggleterm').setup {
  direction = 'window',
  open_mapping = [[<c-n>]],
}
local Terminal = require('toggleterm.terminal').Terminal

local lazygit = Terminal:new {
	cmd = "lazygit",
	hidden = true,
	direction = 'float'
}

function _lazygit_toggle() 
	lazygit:toggle()
end

local glab = Terminal:new {
 	cmd = "glab ci view",
 	hidden = true,
 	direction = 'float'
}

function _glab_toggle() 
	glab:toggle()
end

local ghub = Terminal:new {
 	cmd = "gh run view",
 	hidden = true,
 	direction = 'float'
}

function _ghub_toggle() 
	ghub:toggle()
end
