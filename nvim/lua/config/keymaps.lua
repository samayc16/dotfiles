-- Editor-wide keymaps; plugin and LSP keymaps live with their specs.
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>write<CR><Esc>', { desc = 'Save file' })

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
