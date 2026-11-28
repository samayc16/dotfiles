-- Language servers. Each plugins/lang/*.lua adds entries to `opts.servers`:
-- a vim.lsp.Config merged over nvim-lspconfig's defaults, plus optional keys
--   mason = 'pkg' | false   mason package (default: server name) or false if provided elsewhere
--   enabled = false         declare without starting
--   keys = { { lhs, rhs, desc } }   buffer-local maps while this server is attached
-- `opts.tools` lists extra mason packages (formatters, linters, debug adapters).
local server_keys = {}

local function on_attach(ev)
  local buf = ev.buf
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then return end
  local function map(lhs, rhs, desc, mode) vim.keymap.set(mode or 'n', lhs, rhs, { buffer = buf, desc = 'LSP: ' .. desc }) end

  -- Built in: K hover, grn rename, gra code action. Telescope adds grr grd gri grt gO gW.
  map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('<leader>cr', vim.lsp.buf.rename, '[C]ode [r]ename')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [a]ction', { 'n', 'x' })
  map('<leader>cR', '<cmd>lsp restart<cr>', '[C]ode: [R]estart servers')
  map('<leader>ci', '<cmd>checkhealth vim.lsp<cr>', '[C]ode: LSP [i]nfo')

  if client:supports_method('textDocument/inlayHint', buf) then
    map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf }, { bufnr = buf }) end,
      '[T]oggle inlay [H]ints')
  end
  if client:supports_method('textDocument/codeLens', buf) then
    vim.lsp.codelens.enable(true, { bufnr = buf })
    map('<leader>cl', vim.lsp.codelens.run, '[C]ode [l]ens: run')
  end
  for _, key in ipairs(server_keys[client.name] or {}) do
    map(key[1], key[2], key[3])
  end
end

return {
  {
    'mason-org/mason.nvim',
    lazy = false,
    build = ':MasonUpdate',
    opts = function()
      -- The pinned registry fixes every package's version (pins.txt mason-registry, bumped and
      -- tested nightly); without a pin, the newest registry.
      local registry = require('util.pins').version 'mason-registry'
      return { registries = { 'github:mason-org/mason-registry' .. (registry and '@' .. registry or '') } }
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    opts_extend = { 'tools' },
    opts = { servers = {}, tools = {} },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = on_attach,
      })
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

      for name, server in pairs(opts.servers) do
        if server.enabled ~= false then
          local config = {}
          for key, value in pairs(server) do
            if key ~= 'mason' and key ~= 'enabled' and key ~= 'keys' then config[key] = value end
          end
          server_keys[name] = server.keys
          vim.lsp.config(name, config)
          vim.lsp.enable(name)
        end
      end

      -- run_on_start only fires on VimEnter, which has passed by the time this loads.
      -- Headless, bootstrap.lua runs the sync install; a concurrent async one would
      -- claim the packages and leave the sync wait hanging forever.
      local installer = require 'mason-tool-installer'
      installer.setup { ensure_installed = require('util.mason').packages(opts.servers, opts.tools), run_on_start = false }
      if not require('util.tools').headless then installer.check_install(false) end
    end,
  },
}
