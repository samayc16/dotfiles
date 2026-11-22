-- Dojo UI pieces: highlights, HUD winbar, result screen, info float.
local belts = require 'dojo.belts'

local M = {}

function M.setup_highlights()
  local set = function(name, val) vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', { default = true }, val)) end
  set('DojoTarget', { bg = '#ffd866', fg = '#2d2a2e', bold = true })
  set('DojoTodo', { link = 'DiffText' })
  set('DojoSign', { link = 'DiagnosticWarn' })
  set('DojoStar', { fg = '#ffd866', bold = true })
  set('DojoStarDim', { fg = '#5b595c' })
  set('DojoLabel', { fg = '#78dce8', bold = true })
  set('DojoDim', { link = 'Comment' })
  set('DojoGood', { fg = '#a9dc76', bold = true })
  set('DojoBad', { fg = '#ff6188', bold = true })
  set('DojoTitle', { fg = '#fcfcfa', bold = true })
  for _, belt in ipairs(belts.list) do
    set(belts.hl(belt.id), { fg = belt.color, bold = true })
  end
end

function M.stars(n, total)
  total = total or 3
  return string.rep('★', n) .. string.rep('☆', total - n)
end

function M.bar(fraction, width)
  width = width or 12
  local filled = math.max(0, math.min(width, math.floor(fraction * width + 0.5)))
  return string.rep('█', filled) .. string.rep('░', width - filled)
end

function M.fmt_time(seconds) return ('%02d:%02d'):format(math.floor(seconds / 60), math.floor(seconds % 60)) end

local function esc(s) return (tostring(s):gsub('%%', '%%%%')) end

--- Winbar for the challenge window.
---@param a { ch: table, keys: integer, time: string, stars: integer }
function M.hud(a)
  local ch = a.ch
  local over = a.keys > ch.par
  return table.concat {
    '%#', belts.hl(ch.belt), '# 🥋 ', esc(ch.belt:upper()), ' %*',
    '%#DojoTitle#', esc(ch.id), '  ', esc(ch.title), '%*',
    '%=',
    over and '%#DojoBad#' or '%#DojoGood#', ' ⌨ ', a.keys, '%*', '%#DojoDim#/', ch.par, '%*',
    '   ⏱ ', a.time, '   ',
    '%#DojoStar#', M.stars(a.stars), '%* ',
  }
end

local result_win

function M.close_result()
  if result_win and vim.api.nvim_win_is_valid(result_win) then pcall(vim.api.nvim_win_close, result_win, true) end
  result_win = nil
end

local function centered_float(buf, width, height, title)
  local cfg = {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  }
  return vim.api.nvim_open_win(buf, true, cfg)
end

local function fill(buf, lines, marks)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local ns = vim.api.nvim_create_namespace 'dojo-ui'
  for _, m in ipairs(marks or {}) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
end

--- Result screen after a solve.
---@param a table { ch, keys, seconds, stars, summary, xp, unlocked (belt list), actions = { n=fn, r=fn, m=fn, q=fn } }
function M.result(a)
  M.close_result()
  local ch = a.ch
  local lines, marks = {}, {}
  local function add(text, hl)
    table.insert(lines, text)
    if hl then table.insert(marks, { #lines - 1, 0, #text, hl }) end
  end
  add('')
  add('   ' .. M.stars(a.stars) .. '   ' .. (a.stars == 3 and 'Flawless!' or a.stars == 2 and 'Solid!' or 'Solved!'), 'DojoStar')
  add('')
  add(('   keys    %d   (par %d)'):format(a.keys, ch.par), a.keys <= ch.par and 'DojoGood' or nil)
  add(('   time    %s'):format(M.fmt_time(a.seconds)))
  add(('   xp      +%d   (total %d)'):format(a.summary.xp_gain, a.xp), 'DojoLabel')
  local best = a.summary.best
  add(('   best    %s · %d keys%s'):format(M.stars(best.stars), best.best_keys, a.summary.new_best and '   NEW BEST' or ''))
  for _, belt in ipairs(a.unlocked or {}) do
    add('')
    add(('   🎉 %s belt unlocked: %s'):format(belt.name, belt.theme), belts.hl(belt.id))
  end
  add('')
  add('   reference  ' .. ch.solution .. ('  (%d keys)'):format(require('dojo.keys').count_solution(ch.solution)), 'DojoDim')
  add('')
  add('   [n] next   [r] retry   [m] menu   [q] quit', 'DojoTitle')

  local buf = vim.api.nvim_create_buf(false, true)
  fill(buf, lines, marks)
  local width = 4
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l) + 3)
  end
  result_win = centered_float(buf, math.min(width, vim.o.columns - 4), #lines + 1, ' 🥋 ' .. ch.id .. ' · ' .. ch.title .. ' ')
  for key, fn in pairs(a.actions) do
    vim.keymap.set('n', key, function()
      M.close_result()
      fn()
    end, { buffer = buf, nowait = true })
  end
  vim.keymap.set('n', '<Esc>', function()
    M.close_result()
    a.actions.q()
  end, { buffer = buf, nowait = true })
end

--- Read-only info float (stats screen).
function M.info_float(title, lines, marks)
  local buf = vim.api.nvim_create_buf(false, true)
  fill(buf, lines, marks)
  local width = 20
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l) + 3)
  end
  local win = centered_float(buf, math.min(width, vim.o.columns - 4), math.min(#lines + 1, vim.o.lines - 4), title)
  for _, key in ipairs { 'q', '<Esc>' } do
    vim.keymap.set('n', key, function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, nowait = true })
  end
  return win
end

return M
