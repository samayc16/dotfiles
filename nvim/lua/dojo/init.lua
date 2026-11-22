-- :Dojo, a gamified, offline Vim trainer (VimGolf-style).
--   :Dojo            menu (belts → challenges)
--   :Dojo next       next unsolved challenge
--   :Dojo <id>       play a specific challenge, e.g. :Dojo g-03
--   :Dojo stats      belts, stars, XP, streak
--   :Dojo quit       leave the current challenge
--   :Dojo reset      wipe progress (asks first)
--   :Dojo reload     re-read challenge files (after editing them)
local belts = require 'dojo.belts'
local catalog = require 'dojo.challenges'
local progress = require 'dojo.progress'
local requires = require 'dojo.requires'
local session = require 'dojo.session'
local ui = require 'dojo.ui'

local M = {}

session.open_menu = function() M.menu() end

local function playable(ch) return #requires.missing(ch) == 0 end

--- Next challenge to play: first unsolved & playable in an unlocked belt, else first under ★★★.
function M.suggest()
  local data, cat = progress.load(), catalog.catalog()
  local stats = progress.belt_stats(data, cat)
  local unlocked = {}
  for _, st in ipairs(stats) do
    unlocked[st.belt.id] = st.unlocked
  end
  for _, ch in ipairs(cat.list) do
    if unlocked[ch.belt] and not data.challenges[ch.id] and playable(ch) then return ch end
  end
  for _, ch in ipairs(cat.list) do
    local entry = data.challenges[ch.id]
    if unlocked[ch.belt] and entry and entry.stars < 3 and playable(ch) then return ch end
  end
  return nil
end

local function play(ch, locked_msg)
  if locked_msg and vim.fn.confirm(locked_msg .. '\nPractice it anyway?', '&Yes\n&No', 2) ~= 1 then return end
  session.start(ch)
end

local function challenge_menu(belt_stat)
  local data = progress.load()
  local items = catalog.catalog().by_belt[belt_stat.belt.id]
  vim.ui.select(items, {
    prompt = ('🥋 %s belt · %s'):format(belt_stat.belt.name, belt_stat.belt.theme),
    format_item = function(ch)
      local entry = data.challenges[ch.id]
      local missing = requires.missing(ch)
      local status = #missing > 0 and ('⚠ needs ' .. table.concat(vim.tbl_map(requires.label, missing), ', '))
        or table.concat(ch.teaches, ' ')
      return ('%s  %-5s %-28s %s'):format(ui.stars(entry and entry.stars or 0), ch.id, ch.title, status)
    end,
  }, function(ch)
    if not ch then return end
    local msg = not belt_stat.unlocked
        and ('%s belt is locked (needs %d XP).'):format(belt_stat.belt.name, belt_stat.unlock_xp)
      or nil
    play(ch, msg)
  end)
end

function M.menu()
  local data, cat = progress.load(), catalog.catalog()
  local stats, xp = progress.belt_stats(data, cat)
  local next_ch = M.suggest()
  local items = {}
  if next_ch then table.insert(items, { kind = 'next', ch = next_ch }) end
  for _, st in ipairs(stats) do
    table.insert(items, { kind = 'belt', stat = st })
  end
  table.insert(items, { kind = 'stats' })
  vim.ui.select(items, {
    prompt = ('🥋 Dojo · %d XP · 🔥 %d-day streak'):format(xp, progress.streak(data)),
    format_item = function(item)
      if item.kind == 'next' then return ('▶  Continue: %s  %s'):format(item.ch.id, item.ch.title) end
      if item.kind == 'stats' then return '📊 Stats' end
      local st = item.stat
      local lock = st.unlocked and '' or ('  🔒 %d XP'):format(st.unlock_xp)
      return ('%s %-7s %s %2d/%-2d ★  %s%s'):format(
        st.unlocked and '🥋' or '  ', st.belt.name, ui.bar(st.max_stars > 0 and st.stars / st.max_stars or 0, 10),
        st.stars, st.max_stars, st.belt.theme, lock)
    end,
  }, function(item)
    if not item then return end
    if item.kind == 'next' then return play(item.ch) end
    if item.kind == 'stats' then return M.stats() end
    challenge_menu(item.stat)
  end)
end

function M.stats()
  local data, cat = progress.load(), catalog.catalog()
  local stats, xp = progress.belt_stats(data, cat)
  local rank = progress.rank(data, cat)
  local lines, marks = { '' }, {}
  local function add(text, hl)
    table.insert(lines, text)
    if hl then table.insert(marks, { #lines - 1, 0, #text, hl }) end
  end
  add(('  Rank  %s belt     XP %d     🔥 streak %d (best %d)'):format(rank.name, xp, progress.streak(data), (data.streak or {}).best or 0), belts.hl(rank.id))
  add('')
  for _, st in ipairs(stats) do
    local frac = st.max_stars > 0 and st.stars / st.max_stars or 0
    local text = ('  %-7s %s  %2d/%-2d ★   %2d/%-2d done   %s'):format(st.belt.name, ui.bar(frac, 16), st.stars, st.max_stars, st.done, st.count,
      st.unlocked and st.belt.theme or ('🔒 unlocks at %d XP'):format(st.unlock_xp))
    add(text, belts.hl(st.belt.id))
  end
  add('')
  add('  :Dojo next · :Dojo <id> · press q to close', 'DojoDim')
  ui.setup_highlights()
  ui.info_float(' 📊 Dojo stats ', lines, marks)
end

function M.reset()
  if vim.fn.confirm('Erase ALL Dojo progress?', '&Yes\n&No', 2) ~= 1 then return end
  local path = progress.path()
  if vim.uv.fs_stat(path) then os.rename(path, path .. '.reset-' .. os.time()) end
  vim.notify 'Dojo: progress reset (old file kept as progress.json.reset-*).'
end

local SUBCOMMANDS = { 'next', 'stats', 'quit', 'reset', 'reload' }

function M.command(args)
  local sub = args[1]
  if not sub then return M.menu() end
  if sub == 'next' then
    local ch = M.suggest()
    if ch then return session.start(ch) end
    return vim.notify 'Dojo: everything playable is three-starred. 🏆'
  end
  if sub == 'stats' then return M.stats() end
  if sub == 'quit' or sub == 'stop' then return session.stop() end
  if sub == 'reset' then return M.reset() end
  if sub == 'reload' then
    catalog.reload()
    return vim.notify(('Dojo: %d challenges loaded.'):format(#catalog.catalog().list))
  end
  local ch = catalog.catalog().by_id[sub]
  if not ch then return vim.notify('Dojo: unknown challenge or command: ' .. sub, vim.log.levels.WARN) end
  session.start(ch)
end

function M.complete(arglead)
  local out = {}
  for _, s in ipairs(SUBCOMMANDS) do
    if s:find(arglead, 1, true) == 1 then table.insert(out, s) end
  end
  for _, ch in ipairs(catalog.catalog().list) do
    if ch.id:find(arglead, 1, true) == 1 then table.insert(out, ch.id) end
  end
  return out
end

return M
