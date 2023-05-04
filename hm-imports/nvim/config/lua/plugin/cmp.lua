local cmp = require 'cmp'
local lspkind = require 'lspkind'
local luasnip = require 'luasnip'
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "xynowiki" },
    { name = "luasnip" },
  }, { name = "buffer" }),
  formatting = {
  format = lspkind.cmp_format({
    mode = "symbol_text",
    menu = ({
      buffer = "[Buffer]",
      nvim_lsp = "[LSP]",
      luasnip = "[LuaSnip]",
      nvim_lua = "[Lua]",
      latex_symbols = "[Latex]",
    })
  }),
},
})
