-- Persistent progress: best stars per challenge, XP, belts, daily streak.
-- Stored as JSON at stdpath('data')/dojo/progress.json, written atomically.
-- All update functions return NEW tables; nothing passed in is mutated.
local belts = require 'dojo.belts'

local M = {}
local VERSION = 1

local function today() return os.date '%Y-%m-%d' end
local function yesterday() return os.date('%Y-%m-%d', os.time() - 86400) end

function M.path() return vim.fn.stdpath 'data' .. '/dojo/progress.json' end

local function empty()
  return { version = VERSION, challenges = {}, streak = { count = 0 }, created = today() }
end

--- Load progress; a missing file means a fresh start, a corrupt one is set aside.
function M.load()
  local path = M.path()
  local f = io.open(path, 'r')
  if not f then return empty() end
  local raw = f:read '*a'
  f:close()
  local ok, data = pcall(vim.json.decode, raw)
  if not ok or type(data) ~= 'table' or type(data.challenges) ~= 'table' then
    local backup = ('%s.corrupt-%d'):format(path, os.time())
    os.rename(path, backup)
    vim.notify(('Dojo: progress file was unreadable, moved it to %s and started fresh.'):format(backup), vim.log.levels.WARN)
    return empty()
  end
  return vim.tbl_extend('force', empty(), data, {
    streak = type(data.streak) == 'table' and data.streak or { count = 0 },
  })
end

---@return boolean ok
function M.save(data)
  local path = M.path()
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  local tmp = path .. '.tmp'
  local f, err = io.open(tmp, 'w')
  if not f then
    vim.notify('Dojo: could not save progress: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  f:write(vim.json.encode(data))
  f:close()
  local ok, rename_err = os.rename(tmp, path)
  if not ok then
    vim.notify('Dojo: could not save progress: ' .. tostring(rename_err), vim.log.levels.ERROR)
    return false
  end
  return true
end

--- Stars for a run: ★★★ at or under par, ★★ within 1.5× par, ★ otherwise.
function M.stars(keys, par)
  if not par or keys <= par then return 3 end
  if keys <= math.ceil(par * 1.5) then return 2 end
  return 1
end

local function next_streak(streak, day)
  if streak.last_day == day then return streak end
  local count = streak.last_day == yesterday() and (streak.count or 0) + 1 or 1
  return { count = count, last_day = day, best = math.max(streak.best or 0, count) }
end

--- Current streak (0 if the last practice day was before yesterday).
function M.streak(data)
  local s = data.streak or {}
  if s.last_day == today() or s.last_day == yesterday() then return s.count or 0 end
  return 0
end

--- Record a solved run. Returns the new progress table and a summary of what changed.
---@param result { stars: integer, keys: integer, seconds: number }
function M.record(data, challenge, result)
  local prev = data.challenges[challenge.id] or {}
  local day = today()
  local entry = {
    stars = math.max(prev.stars or 0, result.stars),
    best_keys = prev.best_keys and math.min(prev.best_keys, result.keys) or result.keys,
    best_time = prev.best_time and math.min(prev.best_time, result.seconds) or result.seconds,
    completions = (prev.completions or 0) + 1,
    first = prev.first or day,
    last = day,
  }
  local weight = belts.by_id[challenge.belt].weight
  local summary = {
    xp_gain = weight * (entry.stars - (prev.stars or 0)),
    new_best = prev.best_keys == nil or result.keys < prev.best_keys,
    first_time = prev.stars == nil,
    best = entry,
  }
  local updated = vim.tbl_extend('force', {}, data, {
    challenges = vim.tbl_extend('force', {}, data.challenges, { [challenge.id] = entry }),
    streak = next_streak(data.streak or {}, day),
  })
  return updated, summary
end

--- Total XP over the catalog (unknown/removed challenge ids are ignored).
function M.xp(data, catalog)
  local total = 0
  for id, entry in pairs(data.challenges) do
    local ch = catalog.by_id[id]
    if ch then total = total + belts.by_id[ch.belt].weight * (entry.stars or 0) end
  end
  return total
end

--- Per-belt stats in ladder order, including unlock state.
function M.belt_stats(data, catalog)
  local xp = M.xp(data, catalog)
  local stats, available_before = {}, 0
  for _, belt in ipairs(belts.list) do
    local items = catalog.by_belt[belt.id] or {}
    local s = { belt = belt, count = #items, done = 0, stars = 0, max_stars = #items * 3 }
    for _, ch in ipairs(items) do
      local entry = data.challenges[ch.id]
      if entry then
        s.done = s.done + 1
        s.stars = s.stars + (entry.stars or 0)
      end
    end
    s.xp = s.stars * belt.weight
    s.max_xp = s.max_stars * belt.weight
    s.unlock_xp = belt.unlock_xp or math.floor(available_before * belts.UNLOCK_RATIO)
    s.unlocked = xp >= s.unlock_xp
    available_before = available_before + s.max_xp
    table.insert(stats, s)
  end
  return stats, xp
end

--- Highest unlocked belt (the "rank" shown in the HUD).
function M.rank(data, catalog)
  local stats = M.belt_stats(data, catalog)
  local rank = stats[1].belt
  for _, s in ipairs(stats) do
    if s.unlocked then rank = s.belt end
  end
  return rank
end

return M
