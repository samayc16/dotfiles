-- Non-interactive setup of everything the config needs beyond plugins:
-- mason packages (language servers, formatters, linters, debug adapters) and
-- treesitter parsers. Used by the dotfiles installer:
--
--   nvim --headless "+Lazy! restore" +qa                                  # plugins (lockfile)
--   nvim --headless -c 'luafile ~/.config/nvim/scripts/bootstrap.lua'     # this script
--   nvim --headless -c 'luafile ~/.config/nvim/scripts/smoke.lua'         # verify
--
-- Exits 0 when everything is installed, 1 otherwise.
local failed = {}
local function log(fmt, ...) io.stdout:write(fmt:format(...) .. '\n') end

local function step(name, fn)
  log('==> %s', name)
  local ok, err = pcall(fn)
  if not ok then
    table.insert(failed, name)
    log('    FAILED: %s', tostring(err))
  end
end

local function merged_opts(plugin)
  local spec = require('lazy.core.config').spec.plugins[plugin]
  return spec and require('lazy.core.plugin').values(spec, 'opts', false) or {}
end

step('mason registry update', function()
  require('lazy').load { plugins = { 'mason.nvim' } }
  vim.cmd 'MasonUpdate'
end)

step('mason packages (LSPs, formatters, debug adapters)', function()
  -- Loading lspconfig runs plugins/lsp.lua, which hands the full package list to
  -- mason-tool-installer; the Sync command then blocks until every install finishes.
  require('lazy').load { plugins = { 'nvim-lspconfig' } }
  vim.cmd 'MasonToolsInstallSync'
  local registry = require 'mason-registry'
  local missing = vim.tbl_filter(function(name)
    local ok, pkg = pcall(registry.get_package, name)
    return not (ok and pkg:is_installed())
  end, require('util.mason').required())
  if #missing > 0 then error('not installed: ' .. table.concat(missing, ', ')) end
end)

step('treesitter parsers', function()
  local langs = merged_opts('nvim-treesitter').ensure_installed or {}
  log('    %d parsers: %s', #langs, table.concat(langs, ' '))
  require('nvim-treesitter').install(langs):wait(1800000)
  local installed = require('nvim-treesitter').get_installed()
  local missing = vim.tbl_filter(function(lang) return not vim.list_contains(installed, lang) end, langs)
  if #missing > 0 then error('missing parsers: ' .. table.concat(missing, ', ')) end
end)

if #failed == 0 then
  log 'bootstrap: everything installed'
  vim.cmd 'qa!'
else
  log('bootstrap: %d step(s) failed: %s', #failed, table.concat(failed, '; '))
  vim.cmd 'cq!'
end
