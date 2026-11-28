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

-- A stalled download should fail the install, not hang it.
vim.defer_fn(function()
  log 'bootstrap: timed out after 30 minutes'
  vim.cmd 'cq!'
end, 30 * 60 * 1000)

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
  -- mason-tool-installer (without starting installs when headless). UpdateSync installs what's
  -- missing and moves every installed package to the pinned registry's version (newer or older),
  -- blocking until done.
  require('lazy').load { plugins = { 'nvim-lspconfig' } }
  vim.cmd 'MasonToolsUpdateSync'
  local registry = require 'mason-registry'
  local wrong = {}
  for _, name in ipairs(require('util.mason').required()) do
    local ok, pkg = pcall(registry.get_package, name)
    if not (ok and pkg:is_installed()) then
      table.insert(wrong, name .. ' (not installed)')
    elseif pkg:get_installed_version() ~= pkg:get_latest_version() then
      table.insert(wrong, ('%s %s, pinned %s'):format(name, pkg:get_installed_version(), pkg:get_latest_version()))
    end
  end
  if #wrong > 0 then error(table.concat(wrong, ', ')) end
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
