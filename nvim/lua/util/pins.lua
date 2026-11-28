-- Versions from the dotfiles' pins.txt, which sits next to this config's nvim/ directory (in the
-- git clone and in every release). CI bumps them nightly and tests before releasing.
local M = {}

local pins

local function load()
  pins = {}
  local config = vim.uv.fs_realpath(vim.fn.stdpath 'config')
  local path = config and vim.fs.joinpath(vim.fs.dirname(config), 'pins.txt')
  local ok, lines = pcall(vim.fn.readfile, path or '')
  for _, line in ipairs(ok and lines or {}) do
    local name, _, _, version = line:match '^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s*$'
    if name and not vim.startswith(name, '#') then pins[name] = version end
  end
end

--- The pinned version of `name`, or nil when it isn't pinned (or has no release yet).
function M.version(name)
  if not pins then load() end
  local version = pins[name]
  return version ~= '-' and version or nil
end

return M
