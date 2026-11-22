-- Mason packages the config needs, derived from nvim-lspconfig's merged `servers` + `tools`.
local M = {}

---@return string[] sorted, unique
function M.packages(servers, tools)
  local names = vim.deepcopy(tools or {})
  for name, server in pairs(servers or {}) do
    if server.enabled ~= false and server.mason ~= false then table.insert(names, server.mason or name) end
  end
  return vim.fn.uniq(vim.fn.sort(names))
end

function M.required()
  local spec = require('lazy.core.config').spec.plugins['nvim-lspconfig']
  local opts = spec and require('lazy.core.plugin').values(spec, 'opts', false) or {}
  return M.packages(opts.servers, opts.tools)
end

return M
