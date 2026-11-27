-- Minimal Neovim for test_nvim.py: only nvim/lua/plugins/learn.lua (no plugin manager, no
-- overseer, so checks run in :terminal), with notify/select recorded so the test can read them.
vim.g.mapleader = ' '
local spec = dofile(vim.env.LEARN_LUA)[1]
for _, key in ipairs(spec.keys) do
  vim.keymap.set('n', key[1], key[2], { desc = key.desc })
end
spec.config()

_G.T = { notes = {}, choices = {} }
vim.notify = function(msg, level) table.insert(T.notes, { msg = tostring(msg), level = level or vim.log.levels.INFO }) end
vim.ui.select = function(items, _, on_choice)
  T.offered = items
  local pick = table.remove(T.choices, 1)
  on_choice(pick and items[pick] or nil)
end

local function window(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return {
    name = vim.api.nvim_buf_get_name(buf),
    float = vim.api.nvim_win_get_config(win).relative ~= '',
    readonly = vim.bo[buf].readonly,
    listed = vim.bo[buf].buflisted,
    text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'),
  }
end

function T.state()
  local listed = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then table.insert(listed, vim.api.nvim_buf_get_name(buf)) end
  end
  return vim.json.encode {
    current = vim.api.nvim_buf_get_name(0),
    cwd = vim.fn.getcwd(),
    tabs = vim.fn.tabpagenr '$',
    wins = vim.tbl_map(window, vim.api.nvim_tabpage_list_wins(0)),
    listed = listed,
    notes = T.notes,
    offered = T.offered or {},
    modified = vim.bo.modified,
  }
end

--- Replace the current buffer's text with a file's, leaving the buffer modified (unsaved).
function T.type_in(path)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.readfile(path))
  return 'ok'
end

function T.choose(n)
  table.insert(T.choices, n)
  return 'ok'
end
