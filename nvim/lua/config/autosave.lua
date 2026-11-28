-- Autosave: what's on screen is on disk a moment after you stop changing it, so
-- `learn check`, Claude, test runners and other tmux panes never read a stale file.
--
-- When: DELAY_MS after leaving insert mode or a normal-mode change (u, dw, p, ...),
-- along with every other file that change touched (an LSP rename across files); at
-- once on leaving the buffer (into Claude's split, another file), the tmux pane or the
-- app, and on suspend or quit. Never mid-typing: linters and language servers would
-- chase half-written words.
--
-- Never autosaved, because writing them does something, or :q! must still abort:
--   * buffers that aren't plain files: Claude's proposed diff (a write accepts it),
--     oil (a write renames and deletes), help, terminals, scratch; read-only ones;
--   * commit messages, rebase todos, crontab, sudoers, anything under .git/, and
--     files in a temp dir outside a git repo ($EDITOR for zsh's Ctrl-X Ctrl-E,
--     kubectl edit, Claude's Ctrl-G);
--   * a file changed on disk since nvim read it (Claude in another pane, git checkout):
--     you're told once, and :w (keep yours) or :e! (load theirs) decides.
-- Autosaves skip format-on-save (format.lua): text never jumps while you edit, and
-- `u` isn't redone by the formatter. :w still formats. <leader>ta toggles autosave.
local M = {}

local DELAY_MS = 300
local ABORT_FILETYPES = {
  gitcommit = true,
  gitrebase = true,
  jjdescription = true,
  hgcommit = true,
  svn = true,
  crontab = true,
  sudoers = true,
}

local temp_dirs = {}
for _, dir in ipairs { vim.uv.os_tmpdir(), '/tmp', '/var/tmp' } do
  local real = dir and vim.uv.fs_realpath(dir)
  if real then table.insert(temp_dirs, real) end
end

local function in_temp_dir(dir)
  for _, temp in ipairs(temp_dirs) do
    if dir == temp or vim.startswith(dir, temp .. '/') then return true end
  end
  return false
end

--- Changes whenever anyone writes the file. Compared before autosaving: nvim's own
--- "changed since reading" check would stop the write with a y/n prompt.
local function disk_stamp(path)
  local stat = vim.uv.fs_stat(path)
  return stat and ('%d.%d:%d'):format(stat.mtime.sec, stat.mtime.nsec, stat.size) or 'missing'
end

--- Why `buf` can't be autosaved now; nil when it can.
local function skip_reason(buf)
  if vim.g.autosave == false then return 'off' end
  local bo = vim.bo[buf]
  if bo.buftype ~= '' or not bo.modified or not bo.modifiable or bo.readonly or ABORT_FILETYPES[bo.filetype] then
    return 'not a file to autosave'
  end
  local name = vim.api.nvim_buf_get_name(buf)
  local dir = name ~= '' and vim.uv.fs_realpath(vim.fs.dirname(name))
  if not dir then return 'no file or directory to write' end
  if (dir .. '/'):find('/.git/', 1, true) then return 'git metadata' end
  if in_temp_dir(dir) and not vim.fs.root(name, '.git') then return 'a temp file' end
  local stamp = vim.b[buf].autosave_stamp
  if stamp and stamp ~= disk_stamp(name) then return 'changed on disk' end
end

local function warn_once(buf, message)
  if vim.b[buf].autosave_warned then return end
  vim.b[buf].autosave_warned = true
  vim.notify(message, vim.log.levels.WARN, { title = 'autosave' })
end

function M.save(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].autosaving then return end
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':~:.')
  local reason = skip_reason(buf)
  if reason == 'changed on disk' then
    warn_once(buf, name .. ' changed on disk, so it was not autosaved. :w keeps your version, :e! loads theirs.')
  end
  if reason then return end
  vim.b[buf].autosaving = true -- format.lua: no format-on-save for this write
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd 'silent lockmarks update' end)
  vim.b[buf].autosaving = false
  if not ok then warn_once(buf, ('Autosave of %s failed: %s'):format(name, err)) end
end

local function save_all()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then M.save(buf) end
  end
end

-- One timer for every buffer: an LSP rename or code action edits other files too, and
-- they get no TextChanged of their own.
local timer = vim.uv.new_timer()

local function save_soon()
  timer:stop()
  timer:start(
    DELAY_MS,
    0,
    vim.schedule_wrap(function()
      local mode = vim.api.nvim_get_mode()
      if mode.mode:match '^[iR]' then return end -- typing again: InsertLeave saves later
      if mode.blocking or (not mode.mode:match '^n' and mode.mode ~= 't') then return save_soon() end -- mid-command
      save_all()
    end)
  )
end

function M.toggle()
  vim.g.autosave = vim.g.autosave == false
  vim.notify('Autosave: ' .. (vim.g.autosave and 'on' or 'off'), vim.log.levels.INFO, { title = 'autosave' })
  if vim.g.autosave then save_all() end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('user-autosave', { clear = true })
  local function on(events, callback) vim.api.nvim_create_autocmd(events, { group = group, callback = callback }) end

  on({ 'InsertLeave', 'TextChanged' }, save_soon)
  on('BufLeave', function(ev) M.save(ev.buf) end)
  on({ 'FocusLost', 'VimSuspend', 'VimLeavePre' }, save_all)
  on({ 'BufReadPost', 'BufWritePost', 'FileChangedShellPost' }, function(ev)
    vim.b[ev.buf].autosave_stamp = disk_stamp(vim.api.nvim_buf_get_name(ev.buf))
    vim.b[ev.buf].autosave_warned = nil
  end)
  on('BufNewFile', function(ev) vim.b[ev.buf].autosave_stamp = 'missing' end)

  vim.keymap.set('n', '<leader>ta', M.toggle, { desc = '[T]oggle [A]utosave' })
end

return M
