-- `learn` inside nvim: exercises open as buffers (bufferline tabs) with the README in a
-- right split; checks run as overseer tasks in a bottom dock. The CLI (bin/learn) does
-- the real work; this file only drives it.
--
--   <leader>ll pick exercise   <leader>lc check     <leader>lh hint     <leader>ln/lp next/prev
--   <leader>ls solution        <leader>lr README    <leader>ld dashboard   <leader>lD docs
--   :Learn [check|hint|next|prev|solution|giveup|dash|readme|docs [lang]|<track>/<slug>]

local M = {}

local function learn_bin()
  local path = vim.fn.exepath 'learn'
  if path ~= '' then return path end
  -- ~/.config/nvim is a symlink into the dotfiles repo; bin/learn sits next to it
  return vim.fn.resolve(vim.fn.stdpath 'config') .. '/../bin/learn'
end

---@return string? root of the learn workspace for the current buffer / cwd
local function workspace_root() return vim.fs.root(0, '.learn.json') or vim.fs.root(vim.fn.getcwd(), '.learn.json') or vim.g.learn_workspace end

---@param args string[]
---@return vim.SystemCompleted
local function run(args, opts)
  opts = opts or {}
  local env = vim.tbl_extend('force', { NO_COLOR = '1' }, opts.env or {})
  return vim.system(vim.list_extend({ learn_bin() }, args), { text = true, cwd = opts.cwd, env = env }):wait()
end

local function run_json(args, opts)
  local res = run(args, opts)
  if res.code ~= 0 then
    vim.notify(vim.trim(res.stderr ~= '' and res.stderr or res.stdout), vim.log.levels.WARN, { title = 'learn' })
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, res.stdout)
  if not ok then
    vim.notify('learn: unexpected output\n' .. res.stdout, vim.log.levels.ERROR)
    return nil
  end
  return decoded
end

local function require_workspace()
  local root = workspace_root()
  if not root then vim.notify('Not in a learn workspace. <leader>ll picks an exercise.', vim.log.levels.INFO, { title = 'learn' }) end
  return root
end

--- Close unmodified buffers that belong to the previous workspace, so the tab bar
--- only shows the current exercise.
local function close_previous(previous)
  if not previous then return end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].buflisted and not vim.bo[buf].modified and vim.startswith(name, previous .. '/') then pcall(vim.api.nvim_buf_delete, buf, {}) end
  end
end

local function readme_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.fs.basename(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))) == 'README.md' then return win end
  end
end

local function open_readme(root)
  local win = readme_window()
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd.edit(vim.fn.fnameescape(root .. '/README.md'))
  else
    vim.cmd('botright vsplit ' .. vim.fn.fnameescape(root .. '/README.md'))
  end
  vim.bo.readonly = true
  vim.bo.buflisted = false -- keep the buffer tabs for code; the README lives in its split
  vim.cmd 'wincmd p'
end

--- Open an exercise payload from `learn start --print` in this nvim.
function M.open(payload)
  local previous = vim.g.learn_workspace
  vim.g.learn_workspace = payload.workspace
  vim.cmd.cd(vim.fn.fnameescape(payload.workspace))
  local readme = readme_window()
  if readme and #vim.api.nvim_tabpage_list_wins(0) > 1 then vim.api.nvim_win_close(readme, true) end
  -- Open every learner file as a buffer; the main file last so it is focused.
  local files = vim.list_slice(payload.files, 2)
  table.insert(files, payload.files[1])
  for _, file in ipairs(files) do
    vim.cmd.edit(vim.fn.fnameescape(payload.workspace .. '/' .. file))
  end
  if previous and previous ~= payload.workspace then close_previous(previous) end
  open_readme(payload.workspace)
  vim.notify(('%s  ·  <leader>lc check · <leader>lh hint'):format(payload.title), vim.log.levels.INFO, { title = 'learn' })
end

function M.start(key, force)
  local args = { 'start', key, '--print' }
  if force then table.insert(args, '--force') end
  local payload = run_json(args)
  if payload then M.open(payload) end
end

-- `learn next|prev`, staying in the track of the exercise open in this nvim.
local function step(direction)
  local root = workspace_root()
  local track = nil
  if root then
    local ok, marker = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. '/.learn.json'), '\n'))
    track = ok and marker.track or nil
  end
  -- Run from the workspace so the CLI knows which exercise is open.
  local payload = run_json(track and { direction, track, '--print' } or { direction, '--print' }, { cwd = root })
  if payload then M.open(payload) end
end

function M.next() step 'next' end
function M.prev() step 'prev' end

--- Listed buffers under `root` that still differ from the file on disk.
local function unsaved_in(root)
  local names = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].modified and vim.startswith(name, root .. '/') then table.insert(names, vim.fs.basename(name)) end
  end
  return names
end

function M.check()
  local root = require_workspace()
  if not root then return end
  vim.cmd 'silent! wall'
  local unsaved = unsaved_in(root)
  if #unsaved > 0 then -- 'wall' skips readonly buffers and swallows write errors under silent!
    vim.notify(
      ('Could not save %s: the check reads the file on disk, not your edits.'):format(table.concat(unsaved, ', ')),
      vim.log.levels.WARN,
      { title = 'learn' }
    )
  end
  local ok, overseer = pcall(require, 'overseer')
  if not ok then
    vim.cmd('botright 15split | terminal cd ' .. vim.fn.shellescape(root) .. ' && ' .. vim.fn.shellescape(learn_bin()) .. ' check')
    return
  end
  overseer
    .new_task({
      name = 'learn check',
      cmd = { learn_bin(), 'check' },
      cwd = root,
      components = {
        'default',
        { 'unique', replace = true },
        { 'open_output', on_start = 'always', direction = 'dock', focus = false },
      },
    })
    :start()
end

local function float_markdown(text, title)
  local lines = vim.split(vim.trim(text), '\n')
  vim.lsp.util.open_floating_preview(lines, 'markdown', { border = 'rounded', max_width = 100, title = title, focus_id = 'learn' })
end

function M.hint()
  local root = require_workspace()
  if not root then return end
  local res = run({ 'hint' }, { cwd = root })
  -- stderr carries the one-time "this caps the exercise at ★" warning: show it above the hint.
  local text = vim.trim(table.concat({ vim.trim(res.stderr), vim.trim(res.stdout) }, '\n\n'))
  float_markdown(text, ' hint ')
end

function M.solution(giveup)
  local root = require_workspace()
  if not root then return end
  if giveup then run({ 'giveup' }, { cwd = root }) end
  local res = run({ 'solution', '--paths' }, { cwd = root })
  if res.code ~= 0 then
    vim.notify(vim.trim(res.stderr ~= '' and res.stderr or res.stdout), vim.log.levels.WARN, { title = 'learn' })
    return
  end
  local paths = vim.split(vim.trim(res.stdout), '\n', { trimempty = true })
  if #paths == 0 then
    vim.notify('No reference solution for this exercise.', vim.log.levels.INFO, { title = 'learn' })
    return
  end
  for i, path in ipairs(paths) do
    -- `tab sview` (not tabnew + view) so no empty [No Name] buffer is left in the tab bar
    vim.cmd((i == 1 and 'tab sview ' or 'vertical sview ') .. vim.fn.fnameescape(path))
    vim.bo.buflisted = false -- the reference stays out of the exercise's buffer tabs
    vim.bo.bufhidden = 'wipe'
  end
end

function M.toggle_readme()
  local root = require_workspace()
  if not root then return end
  local win = readme_window()
  if win and #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.api.nvim_win_close(win, false)
  else
    open_readme(root)
  end
end

function M.dashboard()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(100, vim.o.columns - 4)
  local height = math.min(30, vim.o.lines - 6)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'rounded',
    title = ' learn ',
    style = 'minimal',
  })
  vim.fn.jobstart({ learn_bin() }, { term = true, env = { LEARN_FORCE_COLOR = '1' } })
  vim.keymap.set('n', 'q', function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, nowait = true })
end

--- Offline reference docs: HTML opens in the browser, Markdown/rST folders open in a picker.
local DOC_LANGS = { 'c', 'cpp', 'rust', 'python', 'haskell', 'swift', 'sv', 'shell' }

local function open_doc(entry)
  if not entry.exists then
    vim.notify(entry.title .. ' is not downloaded: run ~/dotfiles/learn/fetch.sh once with internet', vim.log.levels.WARN)
  elseif type(entry.files) == 'table' and #entry.files > 0 then
    -- A track's READMEs: offer just those (the track dir also holds every reference solution).
    vim.ui.select(entry.files, {
      prompt = entry.title,
      format_item = function(path) return vim.fs.basename(vim.fs.dirname(path)) end,
    }, function(path)
      if path then vim.cmd.view(vim.fn.fnameescape(path)) end
    end)
  elseif entry.kind == 'html' then
    vim.ui.open(entry.path)
  else
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok and vim.fn.isdirectory(entry.path) == 1 then
      builtin.find_files { cwd = entry.path, prompt_title = entry.title }
    else
      vim.cmd.edit(vim.fn.fnameescape(entry.path))
    end
  end
end

function M.docs(lang)
  local function show(chosen)
    local entries = run_json { 'docs', chosen, '--json' }
    if not entries or #entries == 0 then return end
    if #entries == 1 then return open_doc(entries[1]) end
    vim.ui.select(entries, {
      prompt = 'docs: ' .. chosen,
      format_item = function(e) return (e.exists and '  ' or '✗ ') .. e.title end,
    }, function(e)
      if e then open_doc(e) end
    end)
  end
  if lang then return show(lang) end
  local guess = ({
    c = 'c',
    cpp = 'cpp',
    rust = 'rust',
    python = 'python',
    haskell = 'haskell',
    swift = 'swift',
    systemverilog = 'sv',
    verilog = 'sv',
    sh = 'shell',
    bash = 'shell',
  })[vim.bo.filetype]
  local langs = vim.deepcopy(DOC_LANGS)
  if guess then table.sort(langs, function(a, b) return (a == guess) and b ~= guess end) end
  vim.ui.select(langs, { prompt = 'offline docs' }, function(choice)
    if choice then show(choice) end
  end)
end

local function stars(n) return string.rep('★', n) .. string.rep('☆', 3 - n) end

--- Pad to `width` screen cells (string.format counts bytes, so "·" or "★" would skew columns).
local function pad(text, width)
  if vim.fn.strdisplaywidth(text) > width then text = vim.fn.strcharpart(text, 0, width - 1) .. '…' end
  return text .. string.rep(' ', width - vim.fn.strdisplaywidth(text))
end

function M.pick()
  local status = run_json { 'status' }
  if not status then return end
  vim.ui.select(status.tracks, {
    prompt = ('learn · Level %d %s · %d XP · pick a track'):format(status.level, status.title, status.xp),
    format_item = function(t) return ('%s %3d/%-3d'):format(pad(t.name, 34), t.passed, t.total) end,
  }, function(track)
    if not track then return end
    vim.ui.select(track.exercises, {
      prompt = track.name,
      format_item = function(ex)
        local mark = ex.passed and stars(ex.stars) or (ex.locked and ' 🔒' or ' · ')
        return ('%s  %s'):format(mark, ex.title)
      end,
    }, function(ex)
      if ex then M.start(ex.key, true) end
    end)
  end)
end

local SUBCOMMANDS = {
  check = M.check,
  hint = M.hint,
  next = M.next,
  prev = M.prev,
  solution = function() M.solution(false) end,
  giveup = function() M.solution(true) end,
  dash = M.dashboard,
  readme = M.toggle_readme,
}

local function command(opts)
  local arg = vim.trim(opts.args)
  if arg == '' then return M.pick() end
  if SUBCOMMANDS[arg] then return SUBCOMMANDS[arg]() end
  local doc_lang = arg:match '^docs%s*(%S*)$'
  if doc_lang then return M.docs(doc_lang ~= '' and doc_lang or nil) end
  M.start(arg, opts.bang)
end

local function complete(lead)
  local items = vim.tbl_keys(SUBCOMMANDS)
  if lead:find '/' or #lead > 2 then
    local status = run_json { 'status' }
    for _, track in ipairs(status and status.tracks or {}) do
      for _, ex in ipairs(track.exercises) do
        table.insert(items, ex.key)
      end
    end
  end
  return vim.tbl_filter(function(item) return vim.startswith(item, lead) end, items)
end

return {
  {
    name = 'learn',
    dir = vim.fn.stdpath 'config',
    virtual = true, -- no plugin to install: this spec only wires keymaps + :Learn to bin/learn
    cmd = 'Learn',
    keys = {
      { '<leader>ll', M.pick, desc = '[L]earn: pick exercise' },
      { '<leader>lc', M.check, desc = '[L]earn: [c]heck' },
      { '<leader>lh', M.hint, desc = '[L]earn: [h]int (costs ★★)' },
      { '<leader>ln', M.next, desc = '[L]earn: [n]ext exercise' },
      { '<leader>lp', M.prev, desc = '[L]earn: [p]revious exercise' },
      { '<leader>ls', function() M.solution(false) end, desc = '[L]earn: [s]olution (after passing)' },
      { '<leader>lr', M.toggle_readme, desc = '[L]earn: toggle [R]EADME' },
      { '<leader>ld', M.dashboard, desc = '[L]earn: [d]ashboard' },
      { '<leader>lD', function() M.docs() end, desc = '[L]earn: offline [D]ocs (cppreference, Python, Haskell, ...)' },
    },
    config = function()
      vim.api.nvim_create_user_command('Learn', command, {
        nargs = '?',
        bang = true,
        complete = complete,
        desc = 'learn: pick, check, hint, next, solution, giveup, dash, readme, or open <track>/<slug>',
      })
    end,
  },
}
