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

local pipeline = Terminal:new {
 	cmd = "glab ci view",
 	hidden = true,
 	direction = 'float'
}

function _pipeline_toggle() 
	pipeline:toggle()
end
