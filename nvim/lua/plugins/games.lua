-- Vim trainers and games, each lazy-loaded on its command (except hardtime.nvim, a
-- background coach). `:Games` picks from all of them; `play` in a shell lists them too.

-- DOOM ships its shareware WAD; pass it explicitly so :Doom doesn't prompt for one.
local DOOM_WAD = vim.fn.stdpath 'data' .. '/lazy/actually-doom.nvim/iwad/DOOM1.WAD'

-- One entry per picker row. `cmd` is run with :<cmd>; `label` (optional) is what's shown.
-- Entries whose command doesn't exist (e.g. :Dojo before it's installed) are hidden.
local MENU = {
  { group = 'Train', cmd = 'Dojo', desc = 'vim-golf dojo: motions + this config’s keymaps' },
  { group = 'Train', cmd = 'Tutor vim-01-beginner', desc = 'built-in tutor, part 1 (motions, operators, undo)' },
  { group = 'Train', cmd = 'Tutor vim-02-beginner', desc = 'built-in tutor, part 2 (registers, marks, text objects)' },
  { group = 'Train', cmd = 'VimBeGood', desc = 'motion drills: relative jumps, ci{, delete words, whack-a-mole' },
  { group = 'Train', cmd = 'TrainUpDown', desc = 'mark where j / k / H / M / L / gg land in this buffer' },
  { group = 'Train', cmd = 'TrainWord', desc = 'mark where w / b / e / ge / W / B land in this buffer' },
  { group = 'Train', cmd = 'TrainTextObj', desc = 'mark where ( ) { } [[ ]] land in this buffer' },
  { group = 'Train', cmd = 'Typr', desc = 'typing practice' },
  { group = 'Train', cmd = 'TyprStats', desc = 'typing stats dashboard (WPM, accuracy, weak keys)' },
  { group = 'Train', cmd = 'Speedtyper', desc = 'timed typing game (:SpeedtyperSettings to tweak)' },
  { group = 'Train', cmd = 'Hardtime report', desc = 'your most frequent inefficient motions' },
  { group = 'Train', cmd = 'Hardtime toggle', desc = 'turn the motion coach on / off' },
  { group = 'Play', cmd = 'Doom ' .. vim.fn.fnameescape(DOOM_WAD), label = 'Doom', desc = 'actually DOOM (shareware). arrows move, x fire, space use' },
  { group = 'Play', cmd = 'Tetris', desc = 'Tetris' },
  { group = 'Play', cmd = 'KillKillKill', desc = 'killersheep: h / l move, space fire' },
  { group = 'Play', cmd = 'Nvimesweeper', desc = 'Minesweeper' },
  { group = 'Play', cmd = 'Sudoku', desc = 'Sudoku (g? for help)' },
  { group = 'Play', cmd = 'Playtime', desc = 'card games: solitaire, freecell, spider, ...' },
  { group = 'Play', cmd = 'Play2048', desc = '2048' },
  { group = 'Play', cmd = 'BlackJackNewGame', desc = 'Blackjack' },
  { group = 'Play', cmd = 'CellularAutomaton make_it_rain', desc = 'melt the current code buffer (needs treesitter)' },
  { group = 'Play', cmd = 'CellularAutomaton game_of_life', desc = "Conway's life on the current code buffer" },
}

local function format_item(item) return string.format('%-6s %-32s %s', item.group, ':' .. (item.label or item.cmd), item.desc) end

local function command_exists(item) return vim.fn.exists(':' .. item.cmd:match '^%S+') == 2 end

-- Run after VimEnter so `nvim +Games` gets the telescope picker, not the inputlist fallback.
local function after_startup(fn)
  if vim.v.vim_did_enter == 1 then return fn() end
  vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = function() vim.schedule(fn) end })
end

vim.api.nvim_create_user_command('Games', function()
  after_startup(function()
    local items = vim.tbl_filter(command_exists, MENU)
    vim.ui.select(items, { prompt = 'Games', format_item = format_item }, function(choice)
      if choice then vim.cmd(choice.cmd) end
    end)
  end)
end, { desc = 'Pick a Vim game / trainer' })

-- actually-doom compiles a small C binary into stdpath('data') on first :Doom.
-- Do it at install time instead so it's ready offline. Blocks until done.
local function build_doom()
  local result = nil
  require('actually-doom').rebuild {
    result_cb = function(ok, err) result = { ok = ok, err = err } end,
  }
  local finished = vim.wait(10 * 60 * 1000, function() return result ~= nil end, 200)
  if not finished then error('actually-doom: build timed out', 0) end
  if not result.ok then error('actually-doom: build failed: ' .. tostring(result.err), 0) end
end

return {
  -- ── Train ────────────────────────────────────────────────────────────
  { 'ThePrimeagen/vim-be-good', cmd = 'VimBeGood' },
  { 'tjdevries/train.nvim', cmd = { 'TrainUpDown', 'TrainWord', 'TrainTextObj' } },
  { 'nvzone/typr', dependencies = 'nvzone/volt', cmd = { 'Typr', 'TyprStats' }, opts = {} },
  { 'NStefan002/speedtyper.nvim', cmd = { 'Speedtyper', 'SpeedtyperSettings' } },
  { -- Motion coach: hints when you spam hjkl / use arrows, never blocks.
    'm4xshen/hardtime.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      restriction_mode = 'hint',
      disable_mouse = false,
      disabled_keys = { ['<Up>'] = false, ['<Down>'] = false, ['<Left>'] = false, ['<Right>'] = false },
    },
  },

  -- ── Play ─────────────────────────────────────────────────────────────
  { 'seandewar/actually-doom.nvim', cmd = 'Doom', build = build_doom },
  { 'alec-gibson/nvim-tetris', cmd = 'Tetris' },
  { 'seandewar/killersheep.nvim', cmd = 'KillKillKill' },
  { 'seandewar/nvimesweeper', cmd = 'Nvimesweeper' },
  { 'jim-fx/sudoku.nvim', cmd = 'Sudoku', opts = {} },
  { 'rktjmp/playtime.nvim', cmd = 'Playtime' },
  { 'NStefan002/2048.nvim', cmd = 'Play2048', opts = {} },
  { 'alanfortlink/blackjack.nvim', dependencies = 'nvim-lua/plenary.nvim', cmd = { 'BlackJackNewGame', 'BlackJackQuit', 'BlackJackResetScores' } },
  { 'Eandrju/cellular-automaton.nvim', cmd = 'CellularAutomaton' },
}
