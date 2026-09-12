-- Custom plugins on top of kickstart. Each file in this directory is
-- auto-imported by lazy.nvim (see `{ import = 'custom.plugins' }` in init.lua).
return {
  -- Claude Code side panel: <leader>a* (uses `claude` from PATH)
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {},
    keys = {
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },

  -- Visual undo history
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>ut', '<cmd>UndotreeToggle<CR>', desc = 'Toggle Undotree' },
    },
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- Render markdown inline (headings, tables, code fences)
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
    ft = 'markdown',
    opts = {},
    keys = {
      { '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle Markdown rendering' },
    },
  },
}
