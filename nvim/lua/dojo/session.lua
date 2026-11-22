-- One challenge attempt: a dedicated tab with the editable challenge on the left,
-- the target (or mission) on the right, an info panel below it and a live HUD.
local catalog = require 'dojo.challenges'
local keys = require 'dojo.keys'
local loader = require 'dojo.loader'
local progress = require 'dojo.progress'
local requires = require 'dojo.requires'
local ui = require 'dojo.ui'

local M = {}

local ns = vim.api.nvim_create_namespace 'dojo'
local key_ns = vim.api.nvim_create_namespace 'dojo-keys'
local HINT_AFTER_SECONDS = 25

---@type table?
local active

--- Hook for callers (init.lua) to show the menu from the result screen.
M.open_menu = function() end

local function elapsed(s) return (vim.uv.hrtime() - s.started) / 1e9 end

local function in_dir(s, path)
  for _, dir in ipairs(s.dirs) do
    if path:find(dir, 1, true) then return true end
  end
  return false
end

local function set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function render_info(s)
  local ch = s.ch
  local hint = s.hint_shown and (ch.hint or 'No hint for this one. Check the reference after solving!')
    or ('unlocks in %ds or once you pass par'):format(HINT_AFTER_SECONDS)
  local lines = {
    ' Goal   ' .. ch.goal,
    ' Keys   ' .. table.concat(ch.teaches, '  '),
    (' Par    %d keystrokes   (★★★ ≤ %d · ★★ ≤ %d)'):format(ch.par, ch.par, math.ceil(ch.par * 1.5)),
    ' Hint   ' .. hint,
    ' Quit   :Dojo quit     Restart   :Dojo ' .. ch.id,
  }
  set_lines(s.info_buf, lines)
  vim.api.nvim_buf_clear_namespace(s.info_buf, ns, 0, -1)
  for i = 0, #lines - 1 do
    vim.api.nvim_buf_set_extmark(s.info_buf, ns, i, 0, { end_col = 7, hl_group = 'DojoLabel' })
  end
  if not s.hint_shown then vim.api.nvim_buf_set_extmark(s.info_buf, ns, 3, 7, { end_col = #lines[4], hl_group = 'DojoDim' }) end
end

local function update_hud(s)
  if s.done or not vim.api.nvim_win_is_valid(s.win) then return end
  vim.wo[s.win].winbar = ui.hud { ch = s.ch, keys = s.keys, time = ui.fmt_time(elapsed(s)), stars = progress.stars(s.keys, s.ch.par) }
  if not s.hint_shown and (elapsed(s) > HINT_AFTER_SECONDS or s.keys > s.ch.par) then
    s.hint_shown = true
    render_info(s)
  end
end

--- Line-level diff: highlight target lines still to be produced, sign current lines to change.
local function render_diff(s)
  if s.ch.kind ~= 'text' or not vim.api.nvim_buf_is_valid(s.ctx.buf) then return end
  local cur = vim.api.nvim_buf_get_lines(s.ctx.buf, 0, -1, false)
  local diff = (vim.text and vim.text.diff) or vim.diff
  local hunks = diff(table.concat(cur, '\n') .. '\n', table.concat(s.ch.target, '\n') .. '\n', { result_type = 'indices' })
  vim.api.nvim_buf_clear_namespace(s.target_buf, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(s.ctx.buf, ns, 0, -1)
  for _, h in ipairs(hunks) do
    local sa, ca, sb, cb = h[1], h[2], h[3], h[4]
    for l = sb, sb + cb - 1 do
      vim.api.nvim_buf_set_extmark(s.target_buf, ns, l - 1, 0, { line_hl_group = 'DojoTodo', sign_text = '▶', sign_hl_group = 'DojoSign' })
    end
    for l = sa, sa + ca - 1 do
      pcall(vim.api.nvim_buf_set_extmark, s.ctx.buf, ns, l - 1, 0, { sign_text = '±', sign_hl_group = 'DojoSign', priority = 5 })
    end
    if ca == 0 then -- lines must be inserted: mark the line they go after
      pcall(vim.api.nvim_buf_set_extmark, s.ctx.buf, ns, math.max(sa - 1, 0), 0, { sign_text = '+', sign_hl_group = 'DojoSign', priority = 5 })
    end
  end
end

local function render_target(s)
  local ch = s.ch
  if ch.kind == 'text' then
    set_lines(s.target_buf, ch.target)
    local ft = vim.filetype.match { filename = ch.filename } or ''
    local lang = ft ~= '' and vim.treesitter.language.get_lang(ft) or nil
    if not (lang and pcall(vim.treesitter.start, s.target_buf, lang)) and ft ~= '' then vim.bo[s.target_buf].syntax = ft end
    vim.wo[s.target_win].winbar = '%#DojoLabel# 🎯 TARGET %*%#DojoDim# make the left buffer look exactly like this%*'
    render_diff(s)
  else
    local lines = { '', '  ' .. ch.goal, '' }
    for _, step in ipairs(ch.steps or {}) do
      table.insert(lines, '  • ' .. step)
    end
    set_lines(s.target_buf, lines)
    vim.wo[s.target_win].winbar = '%#DojoLabel# 🎯 MISSION %*'
    if ch.kind == 'cursor' then
      local c = ch.cursor
      local line = vim.api.nvim_buf_get_lines(s.ctx.buf, c.row - 1, c.row, false)[1] or ''
      local opts = { sign_text = '◎', sign_hl_group = 'DojoStar', priority = 200 }
      if c.col then
        opts.end_col = math.min(c.col + 1, #line)
        opts.hl_group = 'DojoTarget'
        vim.api.nvim_buf_set_extmark(s.ctx.buf, ns, c.row - 1, c.col, opts)
      else
        opts.line_hl_group = 'DojoTodo'
        vim.api.nvim_buf_set_extmark(s.ctx.buf, ns, c.row - 1, 0, opts)
      end
    end
  end
end

local function finish(s)
  s.done = true
  vim.on_key(nil, key_ns)
  if s.timer then s.timer:stop() end
  local seconds = elapsed(s)
  local stars = progress.stars(s.keys, s.ch.par)
  local cat = catalog.catalog()
  local before = progress.belt_stats(progress.load(), cat)
  local updated, summary = progress.record(progress.load(), s.ch, { stars = stars, keys = s.keys, seconds = seconds })
  progress.save(updated)
  local after, xp = progress.belt_stats(updated, cat)
  local unlocked = {}
  for i, st in ipairs(after) do
    if st.unlocked and not before[i].unlocked then table.insert(unlocked, st.belt) end
  end
  vim.cmd.stopinsert()
  local ch = s.ch
  ui.result {
    ch = ch, keys = s.keys, seconds = seconds, stars = stars, summary = summary, xp = xp, unlocked = unlocked,
    actions = {
      n = function()
        local nxt = catalog.after(ch)
        if nxt then M.start(nxt) else M.stop(); vim.notify 'Dojo: that was the last challenge. 🏆' end
      end,
      r = function() M.start(ch) end,
      m = function() M.stop(); M.open_menu() end,
      q = function() M.stop() end,
    },
  }
  if M.on_finish then M.on_finish(s, stars) end
end

local function evaluate(s)
  if active ~= s or s.done then return end
  if vim.api.nvim_get_mode().mode ~= 'n' then return end
  render_diff(s)
  if loader.solved(s.ch, s.ctx) then finish(s) end
end

local function schedule_eval(s)
  vim.schedule(function() evaluate(s) end)
end

local function on_key(_, typed)
  local s = active
  if not s or s.done or not typed or typed == '' then return end
  if vim.api.nvim_get_current_tabpage() ~= s.tab then return end
  local n = keys.count_typed(typed)
  if n == 0 then return end
  s.keys = s.keys + n
  -- Re-check after the key is processed; autocmds alone miss some cases (e.g. :normal, feedkeys).
  vim.schedule(function()
    update_hud(s)
    evaluate(s)
  end)
end

local function side_window_opts(win, wrap)
  local wo = vim.wo[win]
  wo.number, wo.relativenumber, wo.cursorline = false, false, false
  wo.signcolumn, wo.foldcolumn, wo.statuscolumn = 'yes:1', '0', ''
  wo.wrap, wo.list = wrap, false
end

local function attach_autocmds(s)
  local group = vim.api.nvim_create_augroup('dojo-session', { clear = true })
  s.augroup = group
  local function in_tab() return vim.api.nvim_get_current_tabpage() == s.tab end
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    buffer = s.ctx.buf,
    callback = function() vim.schedule(function() render_diff(s) end); schedule_eval(s) end,
  })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged', 'BufEnter', 'WinEnter' }, {
    group = group,
    callback = function()
      if in_tab() then schedule_eval(s) end
    end,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(s.win),
    callback = function() vim.schedule(function() if active == s and not s.done then M.stop() end end) end,
  })
  vim.api.nvim_create_autocmd('TabClosed', {
    group = group,
    callback = function()
      if not vim.api.nvim_tabpage_is_valid(s.tab) then vim.schedule(function() if active == s then M.stop() end end) end
    end,
  })
end

---@param ch table challenge
function M.start(ch)
  M.stop()
  local missing = requires.missing(ch)
  if #missing > 0 then
    vim.notify(('Dojo: %s needs %s'):format(ch.id, table.concat(vim.tbl_map(requires.label, missing), ', ')), vim.log.levels.WARN)
    return
  end
  ui.setup_highlights()
  local ctx = loader.prepare(ch)
  vim.cmd.tabnew()
  local tab, win = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_win()
  vim.cmd.tcd(vim.fn.fnameescape(ctx.dir))
  loader.open(ch, ctx, win)

  local target_buf = vim.api.nvim_create_buf(false, true)
  local info_buf = vim.api.nvim_create_buf(false, true)
  local target_win = vim.api.nvim_open_win(target_buf, false, { split = 'right', win = win, width = math.floor(vim.o.columns * 0.42) })
  local info_win = vim.api.nvim_open_win(info_buf, false, { split = 'below', win = target_win, height = 6 })
  side_window_opts(target_win, false)
  side_window_opts(info_win, true)
  vim.wo[info_win].winbar = '%#DojoLabel# ℹ  INFO %*'

  local s = {
    ch = ch, ctx = ctx, tab = tab, win = win, target_buf = target_buf, target_win = target_win,
    info_buf = info_buf, info_win = info_win, keys = 0, started = vim.uv.hrtime(), done = false,
    dirs = { ctx.dir, vim.uv.fs_realpath(ctx.dir) or ctx.dir },
  }
  active = s
  render_target(s)
  render_info(s)
  update_hud(s)
  attach_autocmds(s)
  s.timer = vim.uv.new_timer()
  s.timer:start(1000, 1000, vim.schedule_wrap(function()
    if active ~= s or s.done then return end
    update_hud(s)
    if ch.kind == 'check' then evaluate(s) end
  end))
  vim.api.nvim_set_current_win(win)
  vim.cmd.stopinsert()
  vim.on_key(on_key, key_ns)
end

--- Close the current session (if any) and clean up everything it created.
function M.stop()
  local s = active
  if not s then return end
  active = nil
  s.done = true
  vim.on_key(nil, key_ns)
  if s.timer then
    s.timer:stop()
    s.timer:close()
  end
  pcall(vim.api.nvim_del_augroup_by_id, s.augroup)
  ui.close_result()
  if vim.api.nvim_tabpage_is_valid(s.tab) then
    if #vim.api.nvim_list_tabpages() > 1 then
      pcall(vim.cmd.tabclose, { args = { vim.api.nvim_tabpage_get_number(s.tab) }, bang = true })
    else
      vim.api.nvim_set_current_tabpage(s.tab)
      vim.cmd 'silent! only!'
      vim.cmd.enew()
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if buf == s.ctx.buf or buf == s.target_buf or buf == s.info_buf or (name ~= '' and in_dir(s, name)) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.root_dir and in_dir(s, client.root_dir) then client:stop() end
  end
  loader.cleanup(s.ctx)
end

--- Current session (for tests and `:Dojo` status).
function M.active() return active end

return M
