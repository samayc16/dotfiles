return {
  { 'NMAC427/guess-indent.nvim', event = 'BufReadPre', opts = {} },

  { -- Ctrl-h/j/k/l across nvim splits and tmux panes
    'christoomey/vim-tmux-navigator',
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Navigate left' },
      { '<C-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Navigate down' },
      { '<C-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Navigate up' },
      { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate right' },
    },
  },

  { -- text objects (mini.ai), surround (sa/sd/sr), autopairs, statusline
    'nvim-mini/mini.nvim',
    lazy = false,
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.pairs').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(buf)
        local gs = require 'gitsigns'
        local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc }) end
        local function nav(dir, key)
          return function()
            if vim.wo.diff then
              vim.cmd.normal { key, bang = true }
            else
              gs.nav_hunk(dir)
            end
          end
        end
        local function selected(fn)
          return function() fn { vim.fn.line '.', vim.fn.line 'v' } end
        end
        map('n', ']c', nav('next', ']c'), 'Next git [c]hange')
        map('n', '[c', nav('prev', '[c'), 'Previous git [c]hange')
        map('n', '<leader>hs', gs.stage_hunk, 'Git [h]unk [s]tage (toggle)')
        map('v', '<leader>hs', selected(gs.stage_hunk), 'Git [h]unk [s]tage')
        map('n', '<leader>hr', gs.reset_hunk, 'Git [h]unk [r]eset')
        map('v', '<leader>hr', selected(gs.reset_hunk), 'Git [h]unk [r]eset')
        map('n', '<leader>hS', gs.stage_buffer, 'Git [S]tage buffer')
        map('n', '<leader>hR', gs.reset_buffer, 'Git [R]eset buffer')
        map('n', '<leader>hp', gs.preview_hunk_inline, 'Git [h]unk [p]review')
        map('n', '<leader>hb', function() gs.blame_line { full = true } end, 'Git [b]lame line')
        map('n', '<leader>hd', gs.diffthis, 'Git [d]iff against index')
        map('n', '<leader>hD', function() gs.diffthis '@' end, 'Git [D]iff against last commit')
        map('n', '<leader>tb', gs.toggle_current_line_blame, '[T]oggle git [b]lame line')
        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Inner git hunk')
      end,
    },
  },

  { -- `-` opens the parent directory; edit the listing and :w to rename/move/delete
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      keymaps = {
        ['<C-h>'] = false, -- keep tmux/split navigation
        ['<C-l>'] = false,
        ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        ['gR'] = 'actions.refresh',
        ['q'] = 'actions.close',
      },
    },
    keys = { { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' } },
  },

  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = { focus = true },
    keys = {
      { '<leader>q', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Diagnostics (buffer)' },
      { '<leader>Q', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (workspace)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = '[C]ode [s]ymbols outline' },
      { '<leader>cq', '<cmd>Trouble qflist toggle<cr>', desc = '[C]ode [q]uickfix list' },
    },
  },

  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = { { '<leader>ut', '<cmd>UndotreeToggle<CR>', desc = '[U]ndo[t]ree' } },
    init = function() vim.g.undotree_SetFocusWhenToggle = 1 end,
  },

  { -- Same IDE protocol as the VS Code extension: selection context, diffs, /ide from any terminal
    'coder/claudecode.nvim',
    event = 'VeryLazy', -- start the IDE server so `claude` in another tmux pane can /ide-connect
    dependencies = { 'folke/snacks.nvim' },
    opts = { terminal = { split_side = 'right', split_width_percentage = 0.4 } },
    keys = {
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue last Claude conversation' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume a Claude conversation' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Pick Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer to Claude' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send selection to Claude' },
      { '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', ft = 'oil', desc = 'Add file to Claude' },
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept Claude diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny Claude diff' },
    },
  },
}
