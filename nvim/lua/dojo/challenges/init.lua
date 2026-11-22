-- Challenge catalog: loads lua/dojo/challenges/<belt>.lua for every belt,
-- normalises each entry and validates its shape.
--
-- Challenge fields (see any belt file for examples):
--   id, title, goal               unique id, short title, one-line instruction
--   teaches = { 'ciw', ... }      keys/ideas practised (shown in the UI)
--   ext / filename                temp file extension or full name (filetype, LSP, treesitter)
--   start = { lines }             initial buffer
--   target = { lines }            text goal ...
--   cursor = { row=, col=|match=, offset= }   ... or cursor goal (col omitted = any column) ...
--   check = function(ctx) -> ok, msg         ... or custom state goal
--   from = { row=, col=|match= }  starting cursor (default 1,1)
--   par, solution, hint           keystroke par, reference keys (<leader> ok), hint text
--   requires = { ... }            see dojo.requires
--   replay = false                selftest can't replay it headless (LSP, UI pickers, ...)
--   setup(ctx) / on_open(ctx)     hooks: before the file opens (write extra files, git init)
--                                 and after (inject diagnostics, add buffers)
--   opts = { bo/wo overrides }    e.g. { shiftwidth = 2 } or { foldmethod = 'expr' }
local belts = require 'dojo.belts'

local M = {}
local cache

local function resolve_pos(pos, lines, label, id)
  if not pos then return nil end
  local row = pos.row or pos[1]
  assert(type(row) == 'number' and lines[row], ('%s: %s.row out of range'):format(id, label))
  local col0
  if pos.match then
    local s = lines[row]:find(pos.match, 1, true)
    assert(s, ('%s: %s.match %q not found on row %d'):format(id, label, pos.match, row))
    col0 = s - 1 + (pos.offset or 0)
  elseif pos.col or pos[2] then
    col0 = (pos.col or pos[2]) - 1
  end
  return { row = row, col = col0 }
end

local function normalise(raw, belt, order)
  local id = raw.id
  assert(type(id) == 'string', ('challenge #%d in %s has no id'):format(order, belt.id))
  assert(type(raw.goal) == 'string', id .. ': missing goal')
  assert(type(raw.start) == 'table' and #raw.start > 0, id .. ': missing start lines')
  assert(raw.target or raw.cursor or raw.check, id .. ': needs target, cursor or check')
  assert(type(raw.par) == 'number', id .. ': missing par')
  assert(type(raw.solution) == 'string', id .. ': missing solution')
  local kind = raw.target and 'text' or raw.cursor and 'cursor' or 'check'
  local ext = raw.ext or 'txt'
  return vim.tbl_extend('force', raw, {
    belt = belt.id,
    order = order,
    kind = kind,
    ext = ext,
    filename = raw.filename or ('dojo.' .. ext),
    teaches = raw.teaches or {},
    requires = raw.requires or {},
    from = resolve_pos(raw.from, raw.start, 'from', id) or { row = 1, col = 0 },
    cursor = resolve_pos(raw.cursor, raw.start, 'cursor', id),
  })
end

--- Load (once) and return { list, by_id, by_belt }.
function M.catalog()
  if cache then return cache end
  local list, by_id, by_belt = {}, {}, {}
  for _, belt in ipairs(belts.list) do
    by_belt[belt.id] = {}
    local ok, items = pcall(require, 'dojo.challenges.' .. belt.id)
    if not ok then
      vim.notify(('Dojo: could not load %s belt: %s'):format(belt.id, items), vim.log.levels.ERROR)
    else
      for order, raw in ipairs(items) do
        local good, ch = pcall(normalise, raw, belt, order)
        if not good then
          vim.notify('Dojo: skipping invalid challenge: ' .. tostring(ch), vim.log.levels.ERROR)
        elseif by_id[ch.id] then
          vim.notify('Dojo: duplicate challenge id ' .. ch.id, vim.log.levels.ERROR)
        else
          table.insert(list, ch)
          table.insert(by_belt[belt.id], ch)
          by_id[ch.id] = ch
        end
      end
    end
  end
  cache = { list = list, by_id = by_id, by_belt = by_belt }
  return cache
end

--- Drop the cache (after editing challenge files: `:Dojo reload`).
function M.reload()
  cache = nil
  for name in pairs(package.loaded) do
    if name:match '^dojo%.challenges%.' then package.loaded[name] = nil end
  end
  return M.catalog()
end

--- Challenge after `ch` in ladder order, or nil at the end.
function M.after(ch)
  local list = M.catalog().list
  for i, c in ipairs(list) do
    if c.id == ch.id then return list[i + 1] end
  end
  return nil
end

return M
