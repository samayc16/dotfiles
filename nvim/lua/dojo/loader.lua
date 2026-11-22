-- Puts a challenge on screen: temp workspace on disk, buffer, options, cursor.
-- Shared by the interactive session and the headless selftest so both see
-- exactly the same starting state.
local M = {}

-- Deterministic editing defaults for every challenge; a challenge's `opts` win.
-- Smart indentation is off so `o`, `>>` and friends behave the same everywhere.
local BUF_DEFAULTS = {
  shiftwidth = 4,
  tabstop = 4,
  softtabstop = 0,
  expandtab = true,
  indentexpr = '',
  cindent = false,
  smartindent = false,
  autoindent = true,
  textwidth = 0,
}

--- Create the temp workspace and write the challenge file (plus any setup files).
---@return { dir: string, file: string, state: table }
function M.prepare(ch)
  local dir = vim.fn.tempname() .. '-dojo-' .. ch.id
  vim.fn.mkdir(dir, 'p')
  local file = dir .. '/' .. ch.filename
  vim.fn.mkdir(vim.fs.dirname(file), 'p')
  local ctx = { dir = dir, file = file, state = {}, challenge = ch }
  if ch.setup then ch.setup(ctx) end
  vim.fn.writefile(ch.start, file)
  return ctx
end

--- Open the prepared file in `win` and apply options + starting cursor.
---@return integer buf
function M.open(ch, ctx, win)
  vim.api.nvim_win_call(win, function() vim.cmd('noswapfile edit! ' .. vim.fn.fnameescape(ctx.file)) end)
  local buf = vim.api.nvim_win_get_buf(win)
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].undofile = false

  for name, value in pairs(BUF_DEFAULTS) do
    vim.bo[buf][name] = value
  end
  for name, value in pairs(ch.opts or {}) do
    local info = vim.api.nvim_get_option_info2(name, {})
    if info.scope == 'win' then
      vim.wo[win][name] = value
    elseif info.scope == 'buf' then
      vim.bo[buf][name] = value
    end -- global options are ignored so a challenge never leaks settings
  end

  -- Fresh undo history: the challenge starts from a clean slate
  local undolevels = vim.bo[buf].undolevels
  vim.bo[buf].undolevels = -1
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, ch.start)
  vim.bo[buf].undolevels = undolevels
  vim.bo[buf].modified = false

  pcall(vim.api.nvim_win_set_cursor, win, { ch.from.row, ch.from.col or 0 })
  ctx.buf, ctx.win = buf, win
  if ch.on_open then ch.on_open(ctx) end
  if ch.kind == 'cursor' then vim.bo[buf].modifiable = false end
  return buf
end

local function lines_equal(a, b)
  if #a ~= #b then return false end
  for i = 1, #a do
    if a[i] ~= b[i] then return false end
  end
  return true
end

--- Is the challenge solved in the current state?
---@return boolean solved, string? message
function M.solved(ch, ctx)
  if ch.kind == 'text' then
    if not vim.api.nvim_buf_is_valid(ctx.buf) then return false end
    return lines_equal(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false), ch.target)
  end
  if ch.kind == 'cursor' then
    if vim.api.nvim_get_current_buf() ~= ctx.buf then return false end
    local pos = vim.api.nvim_win_get_cursor(0)
    return pos[1] == ch.cursor.row and (ch.cursor.col == nil or pos[2] == ch.cursor.col)
  end
  local ok, solved, msg = pcall(ch.check, ctx)
  if not ok then return false, 'check error: ' .. tostring(solved) end
  return solved == true, msg
end

--- Remove the temp workspace.
function M.cleanup(ctx)
  if ctx and ctx.dir and ctx.dir:find('-dojo-', 1, true) then vim.fn.delete(ctx.dir, 'rf') end
end

return M
