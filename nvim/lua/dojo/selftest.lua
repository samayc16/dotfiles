-- Headless self-test for :Dojo.
--
--   Replay every reference solution:
--     nvim --headless --clean --cmd 'set rtp^=~/dotfiles/nvim' -c "lua require('dojo.selftest').run()"
--   Smoke-test the interactive session UI (use a throwaway XDG_DATA_HOME):
--     XDG_DATA_HOME=$(mktemp -d) nvim --headless --clean --cmd 'set rtp^=~/dotfiles/nvim' \
--       -c "lua require('dojo.selftest').smoke()"
--
-- Exits non-zero (cquit) on any failure so it can gate commits.
local catalog = require 'dojo.challenges'
local keys = require 'dojo.keys'
local loader = require 'dojo.loader'
local requires = require 'dojo.requires'

local M = {}

local function out(msg) io.stdout:write(msg .. '\n') end

--- Make the headless editor look like the real config for what challenges rely on:
--- leader, mini.ai/surround (from lazy's install dir) and the config's own keymaps.
local function setup_env()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.o.hidden = true
  vim.o.shortmess = vim.o.shortmess .. 'AsS'
  vim.o.report = 100000
  vim.o.more = false
  local mini = vim.fn.stdpath 'data' .. '/lazy/mini.nvim'
  if vim.uv.fs_stat(mini) then
    vim.opt.rtp:append(mini)
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
  end
  local keymaps = vim.api.nvim_get_runtime_file('lua/config/keymaps.lua', false)[1]
  if keymaps then dofile(keymaps) end
end

local function wipe_dir_buffers(ctx)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if buf == ctx.buf or (name ~= '' and name:find(ctx.dir, 1, true)) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
  end
end

--- Replay one challenge. Returns status ('pass'|'fail'|'skip'), detail, counted keys.
function M.replay(ch)
  if ch.replay == false then return 'skip', 'interactive only (replay = false)' end
  local missing = requires.missing(ch)
  if #missing > 0 then return 'skip', 'needs ' .. table.concat(missing, ', ') end

  vim.cmd 'silent! only!'
  vim.cmd 'silent! enew!'
  local ctx = loader.prepare(ch)
  local win = vim.api.nvim_get_current_win()
  local ok_open, open_err = pcall(loader.open, ch, ctx, win)
  if not ok_open then
    loader.cleanup(ctx)
    return 'fail', 'open: ' .. tostring(open_err)
  end
  if loader.solved(ch, ctx) then
    wipe_dir_buffers(ctx)
    loader.cleanup(ctx)
    return 'fail', 'already solved before any key was pressed'
  end

  local count = 0
  local ns = vim.api.nvim_create_namespace 'dojo-selftest'
  vim.on_key(function(_, typed)
    if typed and typed ~= '' then count = count + keys.count_typed(typed) end
  end, ns)
  local ok_keys, key_err = pcall(vim.api.nvim_feedkeys, vim.api.nvim_replace_termcodes(ch.solution, true, true, true), 'xt', false)
  vim.on_key(nil, ns)
  vim.wait(50) -- let scheduled work (e.g. diagnostics floats) settle

  local solved, msg = loader.solved(ch, ctx)
  local detail
  if not ok_keys then
    detail = 'keys error: ' .. tostring(key_err)
  elseif not solved then
    local got = ch.kind == 'text' and table.concat(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false), '⏎')
      or vim.inspect(vim.api.nvim_win_get_cursor(0))
    detail = ('not solved (%s) got: %s'):format(msg or ch.kind, got)
  elseif count > ch.par then
    detail = ('over par: %d keys > par %d'):format(count, ch.par)
  end
  wipe_dir_buffers(ctx)
  loader.cleanup(ctx)
  if detail then return 'fail', detail, count end
  return 'pass', nil, count
end

function M.run()
  setup_env()
  local cat = catalog.catalog()
  local totals = { pass = 0, fail = 0, skip = 0 }
  local per_belt = {}
  for _, ch in ipairs(cat.list) do
    local ok, status, detail, count = pcall(M.replay, ch)
    if not ok then status, detail = 'fail', 'crash: ' .. tostring(status) end
    totals[status] = totals[status] + 1
    per_belt[ch.belt] = per_belt[ch.belt] or { pass = 0, fail = 0, skip = 0 }
    per_belt[ch.belt][status] = per_belt[ch.belt][status] + 1
    if status == 'fail' then
      out(('FAIL %-6s %s'):format(ch.id, detail))
    elseif status == 'skip' then
      out(('skip %-6s %s'):format(ch.id, detail))
    elseif count and count < ch.par then
      out(('pass %-6s %d keys (par %d, slack %d)'):format(ch.id, count, ch.par, ch.par - count))
    end
  end
  for _, belt in ipairs(require('dojo.belts').list) do
    local b = per_belt[belt.id] or { pass = 0, fail = 0, skip = 0 }
    out(('%-7s %2d challenges: %2d pass, %d fail, %d skip'):format(belt.id, #cat.by_belt[belt.id], b.pass, b.fail, b.skip))
  end
  out(('TOTAL %d: %d pass, %d fail, %d skip'):format(#cat.list, totals.pass, totals.fail, totals.skip))
  vim.cmd(totals.fail > 0 and 'cquit 1' or 'qall!')
end

--- Which challenges are playable in THIS environment (run inside the real config).
--- Deferred so VimEnter-loaded plugins (telescope maps) are in place, as in real use.
function M.requirements()
  vim.defer_fn(M._requirements, 300)
end

function M._requirements()
  local playable, blocked = 0, 0
  for _, ch in ipairs(catalog.catalog().list) do
    local missing = requires.missing(ch)
    if #missing == 0 then
      playable = playable + 1
    else
      blocked = blocked + 1
      out(('blocked %-6s needs %s'):format(ch.id, table.concat(missing, ', ')))
    end
  end
  out(('REQUIREMENTS: %d playable, %d blocked'):format(playable, blocked))
  vim.cmd(blocked > 0 and 'cquit 1' or 'qall!')
end

-- Things that must settle before keys make sense (async attach).
local READY = {
  ['exe:lua-language-server'] = function(buf) return #vim.lsp.get_clients { bufnr = buf } > 0 end,
  gitsigns = function(buf) return vim.b[buf].gitsigns_status_dict ~= nil end,
}

--- Split a solution into chunks typed in one go each, pausing between them so async UIs
--- (pickers, oil, LSP prompts) can render. Default: pause before every <CR>.
--- A challenge may override with `drive = { 'chunk1', 'chunk2', ... }`.
local function chunks(ch)
  if ch.drive then return ch.drive end
  local notation = vim.fn.keytrans(vim.api.nvim_replace_termcodes(ch.solution, true, true, true))
  local list, current, i = {}, '', 1
  while i <= #notation do
    local tok = notation:match('^<[^<>]+>', i) or notation:sub(i, i + vim.str_utf_end(notation, i))
    if tok == '<CR>' and current ~= '' then
      table.insert(list, current)
      current = ''
    end
    current = current .. tok
    i = i + #tok
  end
  if current ~= '' then table.insert(list, current) end
  return list
end

--- Drive the interactive-only (replay = false) challenges through the real main loop,
--- one typed key at a time. Run inside the REAL config after plugins are installed:
---   nvim --headless -c "lua require('dojo.selftest').interactive()"
--- Pass ids to restrict: interactive({ 'k-09', 'k-13' }).
function M.interactive(only)
  local session = require 'dojo.session'
  vim.o.more = false
  local queue = {}
  for _, ch in ipairs(catalog.catalog().list) do
    local wanted = only and vim.tbl_contains(only, ch.id) or (not only and ch.replay == false)
    if wanted then table.insert(queue, ch) end
  end
  local results = {}
  local finished
  session.on_finish = function(_, stars) finished = stars end

  local function report()
    local fails = 0
    for _, r in ipairs(results) do
      out(('%-4s %-6s %s'):format(r.status, r.id, r.detail or ''))
      if r.status == 'FAIL' then fails = fails + 1 end
    end
    out(('INTERACTIVE: %d run, %d fail'):format(#results, fails))
    vim.cmd(fails > 0 and 'cquit 1' or 'qall!')
  end

  local function run_next(i)
    local ch = queue[i]
    if not ch then return report() end
    local missing = requires.missing(ch)
    if #missing > 0 then
      table.insert(results, { status = 'skip', id = ch.id, detail = 'needs ' .. table.concat(missing, ', ') })
      return vim.schedule(function() run_next(i + 1) end)
    end
    finished = nil
    session.start(ch)
    local s = session.active()
    local buf = s.ctx.buf
    local deadline = vim.uv.now() + 20000
    local function ready()
      for _, req in ipairs(ch.requires) do
        if READY[req] and not READY[req](buf) then return false end
      end
      return true
    end
    local keys_list = chunks(ch)
    local function done(status, detail)
      table.insert(results, { status = status, id = ch.id, detail = detail })
      io.stderr:write(('… %s %s %s\n'):format(status, ch.id, detail or ''))
      session.stop()
      vim.defer_fn(function() run_next(i + 1) end, 100)
    end
    local function await_result(t0)
      if finished then return done('pass', ('%d★ in %d keys (par %d)'):format(finished, s.keys, ch.par)) end
      if vim.uv.now() - t0 > 8000 then
        local _, msg = loader.solved(ch, s.ctx)
        return done('FAIL', 'not solved after keys: ' .. tostring(msg))
      end
      vim.defer_fn(function() await_result(t0) end, 100)
    end
    local function type_key(k)
      if k > #keys_list then return await_result(vim.uv.now()) end
      vim.api.nvim_input(keys_list[k])
      vim.defer_fn(function() type_key(k + 1) end, 1500)
    end
    local function wait_ready()
      if ready() then return vim.defer_fn(function() type_key(1) end, 600) end
      if vim.uv.now() > deadline then return done('FAIL', 'never became ready (LSP/gitsigns attach)') end
      vim.defer_fn(wait_ready, 200)
    end
    wait_ready()
  end
  vim.defer_fn(function() run_next(1) end, 500)
end

--- Drive a real interactive session headless: start → solve → result → quit.
function M.smoke()
  local session = require 'dojo.session'
  local progress = require 'dojo.progress'
  local failures = {}
  local function expect(cond, what)
    if not cond then table.insert(failures, what) end
  end
  local finished_with
  session.on_finish = function(_, stars) finished_with = stars end

  local ch = catalog.catalog().by_id['w-01'] or catalog.catalog().list[1]
  local tabs_before = #vim.api.nvim_list_tabpages()
  session.start(ch)
  local s = session.active()
  expect(s ~= nil, 'session started')
  expect(#vim.api.nvim_list_tabpages() == tabs_before + 1, 'session opened a tab')
  expect(vim.wo[s.win].winbar:find('⌨', 1, true) ~= nil, 'HUD winbar rendered')

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(ch.solution, true, true, true), 'xt', false)
  vim.wait(1000, function() return finished_with ~= nil end, 20)
  expect(finished_with == 3, 'finish callback fired with 3 stars (got ' .. tostring(finished_with) .. ')')
  expect(s.keys == keys.count_solution(ch.solution), ('HUD counted %d keys, solution has %d'):format(s.keys, keys.count_solution(ch.solution)))

  local data = progress.load()
  expect(data.challenges[ch.id] and data.challenges[ch.id].stars == 3, 'progress.json recorded 3 stars')
  expect(vim.uv.fs_stat(progress.path()) ~= nil, 'progress.json written to ' .. progress.path())
  expect(progress.streak(data) == 1, 'streak started')

  local float_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then float_open = true end
  end
  expect(float_open, 'result float shown')

  vim.api.nvim_feedkeys('q', 'xt', false)
  vim.wait(200)
  expect(session.active() == nil, 'q closed the session')
  expect(#vim.api.nvim_list_tabpages() == tabs_before, 'session tab closed')
  expect(not vim.uv.fs_stat(s.ctx.dir), 'temp workspace deleted')

  -- Corrupt file handling
  local f = io.open(progress.path(), 'w')
  f:write '{not json'
  f:close()
  local fresh = progress.load()
  expect(next(fresh.challenges) == nil, 'corrupt progress file → fresh start')

  -- Menu builds without errors (stub vim.ui.select)
  local seen = 0
  local orig = vim.ui.select
  vim.ui.select = function(items, opts, cb)
    for _, it in ipairs(items) do
      opts.format_item(it)
      seen = seen + 1
    end
    cb(nil)
  end
  require('dojo').menu()
  vim.ui.select = orig
  expect(seen >= 9, 'menu rendered belt rows')

  if #failures == 0 then
    out 'SMOKE OK: session, HUD, key count, win detection, progress, result float, cleanup, menu'
    vim.cmd 'qall!'
  else
    for _, msg in ipairs(failures) do
      out('SMOKE FAIL: ' .. msg)
    end
    vim.cmd 'cquit 1'
  end
end

return M
