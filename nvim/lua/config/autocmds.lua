local function augroup(name) return vim.api.nvim_create_augroup('user-' .. name, { clear = true }) end
local autocmd = vim.api.nvim_create_autocmd

autocmd('TextYankPost', {
  group = augroup 'yank-highlight',
  callback = function() vim.hl.on_yank() end,
})

autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup 'checktime',
  desc = 'Reload files changed outside nvim (git, Claude, formatters)',
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd.checktime() end
  end,
})

autocmd('BufReadPost', {
  group = augroup 'last-position',
  callback = function(ev)
    if vim.bo[ev.buf].filetype:match '^git' or vim.b[ev.buf].last_pos_restored then return end
    vim.b[ev.buf].last_pos_restored = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Back in a terminal you left while typing (Ctrl-h out of Claude, Ctrl-l back in): keep
-- typing, no `i` first. One you left in normal mode (scrolled back) stays in normal mode.
local terminal_resume = augroup 'terminal-resume'
autocmd('WinLeave', {
  group = terminal_resume,
  callback = function()
    if vim.bo.buftype == 'terminal' then vim.b.terminal_resume = vim.api.nvim_get_mode().mode == 't' end
  end,
})
autocmd({ 'WinEnter', 'BufEnter' }, {
  group = terminal_resume,
  callback = function()
    if vim.bo.buftype == 'terminal' and vim.b.terminal_resume and vim.api.nvim_get_mode().mode ~= 't' then vim.cmd.startinsert() end
  end,
})

autocmd('VimResized', {
  group = augroup 'resize-splits',
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd.tabnext(tab)
  end,
})

autocmd('FileType', {
  group = augroup 'close-with-q',
  pattern = { 'help', 'qf', 'man', 'checkhealth', 'notify', 'startuptime', 'dap-float' },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = ev.buf, silent = true, desc = 'Close window' })
  end,
})

autocmd('FileType', {
  group = augroup 'prose',
  pattern = { 'markdown', 'gitcommit', 'text' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
