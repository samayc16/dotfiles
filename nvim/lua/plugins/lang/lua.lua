-- lua_ls + lazydev (Neovim API and plugin types) + stylua.
return {
  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = {
          mason = 'lua-language-server',
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { disable = { 'missing-fields' } },
              hint = { enable = true },
            },
          },
        },
      },
      tools = { 'stylua' },
    },
  },

  {
    'saghen/blink.cmp',
    opts = {
      sources = {
        default = { 'lazydev' },
        providers = { lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 } },
      },
    },
  },

  { 'stevearc/conform.nvim', opts = { formatters_by_ft = { lua = { 'stylua' } } } },

  {
    'stevearc/overseer.nvim',
    opts = { run = { lua = function(ctx) return { cmd = 'nvim -l ' .. vim.fn.shellescape(ctx.file), cwd = ctx.dir } end } },
  },
}
