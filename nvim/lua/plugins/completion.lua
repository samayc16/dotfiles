-- blink.cmp + LuaSnip. Accept with <C-y>, <Tab> or <CR>; <C-e> closes the menu.
return {
  {
    'saghen/blink.cmp',
    version = '1.*', -- release builds ship the prebuilt Rust matcher
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (vim.fn.executable 'make' == 1) and 'make install_jsregexp' or nil,
        dependencies = { 'rafamadriz/friendly-snippets' },
        config = function()
          require('luasnip').setup { update_events = 'TextChanged,TextChangedI', delete_check_events = 'TextChanged' }
          local loader = require 'luasnip.loaders.from_vscode'
          loader.lazy_load()
          loader.lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
        end,
      },
    },
    opts_extend = { 'sources.default' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = {
          function(cmp)
            if cmp.snippet_active() then return cmp.accept() end
            return cmp.select_and_accept()
          end,
          'snippet_forward',
          'fallback',
        },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        ghost_text = { enabled = true },
        menu = { draw = { treesitter = { 'lsp' } } },
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      signature = { enabled = true },
    },
  },
}
