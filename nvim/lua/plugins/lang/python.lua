-- basedpyright (types, navigation) + ruff (lint, imports, format) + debugpy.
local q = vim.fn.shellescape
local tools = require 'util.tools'

local function project_root(buf)
  return vim.fs.root(buf, { 'pyproject.toml', 'uv.lock', 'setup.py', 'requirements.txt', '.venv', '.git' })
end

--- <root>/.venv/bin/python when present (uv, venv, poetry in-project), else python3.
local function python_for(root)
  local venv = root and (root .. '/.venv/bin/python')
  if venv and vim.fn.executable(venv) == 1 then return venv end
  local system = vim.fn.exepath 'python3'
  return system ~= '' and system or 'python3'
end

return {
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'python', 'requirements', 'rst' } } },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        basedpyright = {
          mason = not tools.old_glibc and 'basedpyright' or false, -- old glibc: the installer's npm build
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard',
                autoImportCompletions = true,
                diagnosticMode = 'openFilesOnly',
                inlayHints = { callArgumentNames = true, variableTypes = true, functionReturnTypes = true },
              },
            },
          },
          -- Settings are sent before on_init runs, so set the interpreter and resend.
          on_init = function(client)
            client.settings = vim.tbl_deep_extend('force', client.settings, { python = { pythonPath = python_for(client.root_dir) } })
            client:notify('workspace/didChangeConfiguration', { settings = client.settings })
          end,
        },
        ruff = {
          on_attach = function(client) client.server_capabilities.hoverProvider = false end, -- basedpyright hovers
        },
      },
      tools = { 'debugpy' },
    },
  },

  { 'stevearc/conform.nvim', opts = { formatters_by_ft = { python = { 'ruff_organize_imports', 'ruff_format' } } } },

  {
    'stevearc/overseer.nvim',
    opts = {
      run = {
        python = function(ctx)
          local root = project_root(ctx.buf) or ctx.dir
          return { cmd = q(python_for(root)) .. ' ' .. q(ctx.file), cwd = root }
        end,
      },
      templates = {
        {
          name = 'pytest',
          condition = { filetype = { 'python' } },
          builder = function()
            local root = project_root(0) or vim.fn.getcwd()
            return { cmd = q(python_for(root)) .. ' -m pytest -q', cwd = root }
          end,
        },
        {
          name = 'pytest: current file',
          condition = { filetype = { 'python' } },
          builder = function()
            local root = project_root(0) or vim.fn.getcwd()
            return { cmd = q(python_for(root)) .. ' -m pytest -q ' .. q(vim.api.nvim_buf_get_name(0)), cwd = root }
          end,
        },
      },
    },
  },

  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      local debugpy = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(vim.fn.executable(debugpy) == 1 and debugpy or 'python3')
      require('dap-python').test_runner = 'pytest'
    end,
    keys = {
      { '<leader>dm', function() require('dap-python').test_method() end, ft = 'python', desc = '[D]ebug test [m]ethod' },
      { '<leader>dk', function() require('dap-python').test_class() end, ft = 'python', desc = '[D]ebug test class' },
    },
  },
}
