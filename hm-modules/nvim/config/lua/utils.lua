-- cool map funciton from https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
utils = {}
utils.map = function(key)
  -- get the extra options
  local opts = {noremap = false}
	for i, v in pairs(key) do
		if (i) == 'string' then opts[i] = v end
	end

  -- basic support for buffer-scoped keybindings
  local buffer = opts.buffer
  opts.buffer = nil

  if buffer then
    vim.api.nvim_buf_set_keymap(0, key[1], key[2], key[3], opts)
  else
    vim.api.nvim_set_keymap(key[1], key[2], key[3], opts)
  end
end

return utils
