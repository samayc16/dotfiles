-- Editor-wide keymaps; plugin and LSP keymaps live with their specs.
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>write<CR><Esc>', { desc = 'Save file' })
-- Shell (readline) editing keys in insert mode and on the : line. In tmux, Ctrl-A is the
-- prefix: press it twice to send it through, as in the shell.
map({ 'i', 'c' }, '<M-BS>', '<C-w>', { desc = 'Delete the word before the cursor' })
map('i', '<C-a>', function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local first = (vim.api.nvim_get_current_line():find '%S' or 1) - 1
  vim.api.nvim_win_set_cursor(0, { row, col == first and 0 or first })
end, { desc = 'Start of line (first non-blank; again for column 0)' })
map('i', '<C-e>', '<End>', { desc = 'End of line (closes the completion menu first)' })
map('c', '<C-a>', '<Home>', { desc = 'Start of line' }) -- Ctrl-E is already end of line there

map('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centred)' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centred)' })
map('n', 'n', 'nzzzv', { desc = 'Next match (centred)' })
map('n', 'N', 'Nzzzv', { desc = 'Previous match (centred)' })

map('x', 'J', ":move '>+1<CR>gv=gv", { desc = 'Move selection down', silent = true })
map('x', 'K', ":move '<-2<CR>gv=gv", { desc = 'Move selection up', silent = true })
map('x', '<', '<gv', { desc = 'Indent left' })
map('x', '>', '>gv', { desc = 'Indent right' })

map('n', '<leader>td', function() require('config.diagnostics').toggle_lines() end, { desc = '[T]oggle [D]iagnostic lines' })
map('n', '<leader>tw', '<cmd>setlocal wrap!<CR>', { desc = '[T]oggle [W]rap' })
map('n', '<leader>ts', '<cmd>setlocal spell!<CR>', { desc = '[T]oggle [S]pell' })
map('n', '<leader>tr', '<cmd>set relativenumber!<CR>', { desc = '[T]oggle [R]elative numbers' })
