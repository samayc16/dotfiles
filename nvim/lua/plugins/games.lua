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
  { group = 'Play', cmd = 'KillKillKill', desc = 'killersheep: h / l move, space fire (needs a 60x35 window)' },
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

-- 2048.nvim draws fixed 5x10 squares and refuses to start below 31x51 cells (any tmux split).
-- Use the largest squares that fit, and say so plainly when even the smallest don't.
local SQUARES_2048 = { { 5, 10 }, { 4, 8 }, { 3, 6 }, { 2, 6 } } -- { height, width }

local function setup_2048()
  local game = require '2048'
  game.setup()
  vim.api.nvim_create_user_command('Play2048', function()
    local g = game.new()
    local ui = vim.api.nvim_list_uis()[1] or { height = vim.o.lines, width = vim.o.columns }
    for _, sq in ipairs(SQUARES_2048) do
      g._square_height, g._square_width = sq[1], sq[2]
      -- the plugin errors unless there are 5 spare rows (scoreboard) and a spare column
      if ui.height > g:calculate_window_height() + 5 and ui.width > g:calculate_window_width() then break end
    end
    g._left_right_animation_interval = g._up_down_animation_interval * (g._square_height + g._vertical_padding)
      / (g._square_width + g._horizontal_padding)
    local ok, err = pcall(g.create_window, g)
    if not ok then
      local small = tostring(err):find 'increase the size' ~= nil
      vim.notify(small and '2048 needs a window of at least 19 rows x 35 columns (tmux: prefix z zooms the pane).' or tostring(err), vim.log.levels.WARN)
    end
  end, { nargs = 0, desc = 'Start 2048' })
end

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
  {
    'NStefan002/speedtyper.nvim',
    cmd = { 'Speedtyper', 'SpeedtyperSettings' },
    -- Its default "echo" messages stop at Press ENTER (e.g. "no sound player installed" on
    -- every launch); use toasts like the rest of the config. "none" is still respected.
    config = function()
      local settings = require 'speedtyper.settings'
      if settings:get_selected 'notify_method' ~= 'echo' then return end
      for method in pairs(settings.general.notify_method) do
        settings.general.notify_method[method] = method == 'notify'
      end
      settings:save()
    end,
  },
  { -- Motion coach: hints when you spam hjkl / use arrows, never blocks.
    'm4xshen/hardtime.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      restriction_mode = 'hint',
      disable_mouse = false,
      disabled_keys = { ['<Up>'] = false, ['<Down>'] = false, ['<Left>'] = false, ['<Right>'] = false },
    },
    config = function(_, opts)
      require('hardtime').setup(opts)
      -- :Hardtime report errors until the first hint is logged; start from an empty log.
      local log = vim.fn.stdpath 'log' .. '/hardtime.nvim.log'
      if not vim.uv.fs_stat(log) then vim.fn.writefile({}, log) end
    end,
  },

  -- ── Play ─────────────────────────────────────────────────────────────
  { 'seandewar/actually-doom.nvim', cmd = 'Doom', build = build_doom, cond = vim.uv.fs_stat(vim.env.HOME .. '/games') ~= nil },
  { 'alec-gibson/nvim-tetris', cmd = 'Tetris' },
  { 'seandewar/killersheep.nvim', cmd = 'KillKillKill' },
  { 'seandewar/nvimesweeper', cmd = 'Nvimesweeper' },
  { 'jim-fx/sudoku.nvim', cmd = 'Sudoku', opts = {} },
  { 'rktjmp/playtime.nvim', cmd = 'Playtime' },
  { 'NStefan002/2048.nvim', cmd = 'Play2048', config = setup_2048 },
  { 'alanfortlink/blackjack.nvim', dependencies = 'nvim-lua/plenary.nvim', cmd = { 'BlackJackNewGame', 'BlackJackQuit', 'BlackJackResetScores' } },
  { 'Eandrju/cellular-automaton.nvim', cmd = 'CellularAutomaton' },
}
