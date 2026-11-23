-- Which compiler / simulator `<leader>rr`, the debugger and clangd's fallback standard use,
-- per language. Choose with `<leader>rc` or `:Toolchain [c|cpp|hdl]`; the choice is saved.
-- Precedence: vim.g.toolchain (e.g. set in config) > saved choice > first one installed.
local M = {}

local STATE = vim.fn.stdpath 'state' .. '/toolchain.json'

local GROUPS = {
  c = { label = 'C compiler', candidates = { 'clang', 'gcc' }, versioned = 'gcc' },
  cpp = { label = 'C++ compiler', candidates = { 'clang++', 'g++' }, versioned = 'g++' },
  hdl = { label = 'HDL simulator', candidates = { 'verilator', 'iverilog' } },
}
local GROUP_OF = { c = 'c', cpp = 'cpp', verilog = 'hdl', systemverilog = 'hdl' }

local function saved()
  local ok, data = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(STATE), '\n')) end)
  return ok and type(data) == 'table' and data or {}
end

--- `gcc-15`, `g++-14`, … on PATH: real GCC where plain `gcc` is Apple clang (Homebrew).
local function versioned(prefix)
  local found = {}
  for dir in vim.gsplit(vim.env.PATH or '', ':', { plain = true }) do
    for _, path in ipairs(vim.fn.globpath(dir, prefix .. '-[0-9]*', false, true)) do
      local name = vim.fs.basename(path)
      if name:match('^' .. vim.pesc(prefix) .. '%-%d+$') and vim.fn.executable(path) == 1 then found[name] = true end
    end
  end
  local names = vim.tbl_keys(found)
  table.sort(names, function(a, b) return tonumber(a:match '%d+$') > tonumber(b:match '%d+$') end)
  return names
end

--- Installed choices for a group, default first.
function M.candidates(group)
  local spec = GROUPS[group]
  local names = vim.list_extend(vim.deepcopy(spec.candidates), spec.versioned and versioned(spec.versioned) or {})
  return vim.tbl_filter(function(name) return vim.fn.executable(name) == 1 end, names)
end

local function chosen(group)
  local name = (vim.g.toolchain or {})[group] or saved()[group]
  if name and vim.fn.executable(name) == 1 then return name end
  return M.candidates(group)[1]
end

--- The tool to use for a filetype (nil if it has no toolchain choice or none is installed).
function M.get(ft) return GROUP_OF[ft] and chosen(GROUP_OF[ft]) end

local function version_line(name)
  local res = vim.system({ name, name == 'iverilog' and '-V' or '--version' }, { text = true }):wait()
  return vim.split(vim.trim(res.stdout ~= '' and res.stdout or res.stderr or ''), '\n')[1] or ''
end

--- Pick for the current buffer's language (or `group`), save it and use it from now on.
function M.pick(group)
  local spec = GROUPS[group or GROUP_OF[vim.bo.filetype]]
  if not spec then
    local why = group and ('Unknown toolchain %q: use c, cpp or hdl.'):format(group)
      or 'No compiler or simulator choice for this filetype (C, C++, Verilog, SystemVerilog).'
    vim.notify(why, vim.log.levels.WARN)
    return
  end
  group = group or GROUP_OF[vim.bo.filetype]
  local current = chosen(group)
  vim.ui.select(M.candidates(group), {
    prompt = spec.label .. ' for <leader>rr',
    format_item = function(name) return ('%s %-10s %s'):format(name == current and '●' or ' ', name, version_line(name)) end,
  }, function(choice)
    if not choice then return end
    local data = vim.tbl_extend('force', saved(), { [group] = choice })
    vim.fn.mkdir(vim.fs.dirname(STATE), 'p')
    vim.fn.writefile({ vim.json.encode(data) }, STATE)
    vim.g.toolchain = vim.tbl_extend('force', vim.g.toolchain or {}, { [group] = choice })
    vim.notify(('%s: %s'):format(spec.label, choice), vim.log.levels.INFO, { title = 'toolchain' })
  end)
end

M.groups = vim.tbl_keys(GROUPS)

return M
