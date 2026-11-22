-- Checks whether a challenge's requirements are met WITHOUT loading plugins.
-- Requirement strings:
--   'mini.surround'      a Lua module (installed plugin, loaded or not)
--   'exe:rg'             an executable on PATH
--   'cmd:UndotreeToggle' an Ex command (lazy.nvim stubs count)
--   'map:n:<C-s>'        a mapping in mode n (lazy.nvim key stubs count)
local M = {}

local function module_available(mod)
  if package.loaded[mod] then return true end
  local rel = mod:gsub('%.', '/')
  local candidates = { 'lua/' .. rel .. '.lua', 'lua/' .. rel .. '/init.lua' }
  for _, c in ipairs(candidates) do
    if #vim.api.nvim_get_runtime_file(c, false) > 0 then return true end
  end
  -- Lazy-loaded plugins are not on 'runtimepath' until loaded: look in their dirs.
  local ok, config = pcall(require, 'lazy.core.config')
  if ok and type(config.plugins) == 'table' then
    for _, plugin in pairs(config.plugins) do
      for _, c in ipairs(candidates) do
        if plugin.dir and vim.uv.fs_stat(plugin.dir .. '/' .. c) then return true end
      end
    end
  end
  return false
end

---@param req string
---@return boolean
function M.check(req)
  local kind, rest = req:match '^(%a+):(.+)$'
  if kind == 'exe' then return vim.fn.executable(rest) == 1 end
  if kind == 'cmd' then return vim.fn.exists(':' .. rest) == 2 end
  if kind == 'map' then
    local mode, lhs = rest:match '^(%a+):(.+)$'
    return mode ~= nil and vim.fn.maparg(lhs, mode) ~= ''
  end
  return module_available(req)
end

--- Requirements that are not met (empty list when the challenge is playable).
---@return string[]
function M.missing(challenge)
  local missing = {}
  for _, req in ipairs(challenge.requires or {}) do
    if not M.check(req) then table.insert(missing, req) end
  end
  return missing
end

--- Human-friendly label: 'exe:rg' → 'rg', 'map:n:<C-s>' → '<C-s> mapping'.
function M.label(req)
  local kind, rest = req:match '^(%a+):(.+)$'
  if kind == 'exe' or kind == 'cmd' then return rest end
  if kind == 'map' then return (rest:gsub('^%a+:', '')) .. ' mapping' end
  return req
end

return M
