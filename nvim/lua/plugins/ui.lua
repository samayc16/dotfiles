return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>a', group = 'Cl[a]ude', mode = { 'n', 'v' } },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode', mode = { 'n', 'v' } },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>l', group = '[L]earn' },
        { '<leader>r', group = '[R]un' },
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>u', group = '[U]ndo' },
        { '<leader>v', group = '[V]erilog' },
        { '<leader>X', group = '[X]code' },
        { 'gr', group = 'LSP' },
      },
    },
    keys = {
      { '<leader>?', function() require('which-key').show { global = false } end, desc = 'Buffer-local keymaps' },
    },
  },

  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 900,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      words = { enabled = true },
      image = { enabled = true }, -- kitty graphics: markdown images, SwiftUI previews
      lazygit = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazy[g]it' },
      { '<leader>gl', function() Snacks.lazygit.log_file() end, desc = '[G]it [l]og for file' },
      { '<leader>gB', function() Snacks.gitbrowse() end, desc = '[G]it [B]rowse on GitHub', mode = { 'n', 'x' } },
      { '<leader>tt', function() Snacks.terminal() end, desc = '[T]oggle [T]erminal' },
      -- terminals send Ctrl-/ as either <C-/> or <C-_>
      { '<C-/>', function() Snacks.terminal() end, desc = 'Toggle terminal', mode = { 'n', 't' } },
      { '<C-_>', function() Snacks.terminal() end, desc = 'which_key_ignore', mode = { 'n', 't' } },
      { ']r', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next reference' },
      { '[r', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Previous reference' },
      { '<leader>sN', function() Snacks.notifier.show_history() end, desc = '[S]earch [N]otifications' },
    },
  },

  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
    keys = {
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = '[S]earch [T]odos' },
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = 'markdown',
    opts = {},
    keys = { { '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', desc = '[T]oggle [M]arkdown rendering' } },
  },

  { 'nvim-tree/nvim-web-devicons', lazy = true },
}
