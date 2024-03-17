local dap = require('dap')
dap.adapters.coreclr = {
  type = 'executable',
  command = '/nix/var/nix/profiles/per-user/ragon/home-manager/home-path/bin/netcoredbg', -- TODO this is a gross hack, please fix
  args = {'--interpreter=vscode'}
}
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
  },
  {
    type = "coreclr",
    name = "attach - netcoredbg",
    mode = "local",
    request = "attach",
    processId = require("dap.utils").pick_process,
  },
}

require'dapui'.setup {}
