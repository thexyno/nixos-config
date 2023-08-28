local lspconfig = require 'lspconfig'
local util = require 'lspconfig.util'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- lsp keymaps
local lsp_attach_keymappings = {
  ['gD'] = 'vim.lsp.buf.declaration()',
  ['gd'] = 'require\'telescope.builtin\'.lsp_definitions()',
  ['K'] = 'vim.lsp.buf.hover()',
  ['gi'] = 'require\'telescope.builtin\'.lsp_implementations()',
  ['<localleader>k'] = 'vim.lsp.buf.signature_help()',
  ['<leader>wa'] = 'vim.lsp.buf.add_workspace_folder()',
  ['<leader>wr'] = 'vim.lsp.buf.remove_workspace_folder()',
  ['<leader>ws'] = 'require\'telescope.builtin\'.lsp_workspace_symbols()',
  ['<leader>wl'] = 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
  ['<leader>D'] = 'require\'telescope.builtin\'.lsp_type_definitions()',
  ['<leader>rn'] = 'vim.lsp.buf.rename()',
  ['<leader>ca'] = 'vim.lsp.buf.code_action()',
  ['gr'] = 'require\'telescope.builtin\'.lsp_references()',
  ['<leader>f'] = 'vim.lsp.buf.format()'
}
local buf_nnoremap_lua = function(bufnr, keys, command)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', keys, '<cmd>lua ' .. command .. '<CR>', { noremap = true, silent = true })
end
local on_lsp_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>:
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  for key, cmd in pairs(lsp_attach_keymappings) do buf_nnoremap_lua(bufnr, key, cmd) end
end

vim.g.markdown_fenced_languages = {
  "ts=typescript"
}
lspconfig.denols.setup { capabilities = capabilities, on_attach = on_lsp_attach, root_dir = util.root_pattern("deno.json", "deno.jsonc") }
lspconfig.gopls.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.pyright.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.nil_ls.setup { capabilities = capabilities, on_attach = on_lsp_attach } -- nix
-- lspconfig.rnix.setup { capabilities = capabilities, on_attach = on_lsp_attach } -- nix
lspconfig.terraformls.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.kotlin_language_server.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.sourcekit.setup { capabilities = capabilities, on_attach = on_lsp_attach, cmd = { "xcrun", "sourcekit-lsp" } } -- swift
lspconfig.tsserver.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.vimls.setup {
  capabilities = capabilities,
  on_attach = on_lsp_attach,
  isNeovim = true,
}

lspconfig.csharp_ls.setup {
  capabilities = capabilities,
  on_attach = on_lsp_attach,
  cmd = { vim.env.HOME .. "/.dotnet/tools/csharp-ls" },
}
lspconfig.ltex.setup { capabilities = capabilities, on_attach = on_lsp_attach }
-- start vscode included language servers
lspconfig.eslint.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.html.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.cssls.setup { capabilities = capabilities, on_attach = on_lsp_attach }
lspconfig.jsonls.setup { capabilities = capabilities, on_attach = on_lsp_attach }
-- end vscode included language servers
lspconfig.texlab.setup { capabilities = capabilities, on_attach = on_lsp_attach, settings = { texlab = {
  build = {
    executable = "tectonic",
    args = { "%f", "--keep-logs", "--synctex" },
    onSave = true,
    forwardSearchAfter = true,
  },
  chktex = { onOpenAndSave = true, },
  forwardSearch = {
    executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
    args = { "-r", "-d", "%l", "%p", "%f" },
  },
} } }
lspconfig.sumneko_lua.setup {
  capabilities = capabilities, on_attach = on_lsp_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        -- Make the LSP aware of Neovim runtime files:
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true)
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = 'space',
          indent_size = '2',
        }
      },
    }
  }
}
-- haskell
lspconfig.hls.setup { capabilities = capabilities, on_attach = on_lsp_attach }



local rt = require("rust-tools")
rt.setup({
  tools = {
    inlay_hints = {
      auto = true,
    },
  },
  server = {
    capabilities = capabilities, on_attach = on_lsp_attach,
  },
})
local ft = require('flutter-tools')
ft.setup {}
