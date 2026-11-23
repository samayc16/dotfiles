-- overseer.nvim: <leader>rr runs the current file (util/runner.lua); <leader>ro picks
-- a project task; <leader>rc / :Toolchain choose the compiler or simulator it uses.
-- Language files add `opts.run[filetype]` builders and `opts.templates`.
return {
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerShell', 'OverseerTaskAction' },
    keys = {
      { '<leader>rr', function() require('util.runner').run() end, desc = '[R]un current file' },
      { '<leader>rR', function() require('util.runner').run_with_args() end, desc = '[R]un file with a[R]gs' },
      { '<leader>ro', '<cmd>OverseerRun<cr>', desc = '[R]un project task' },
      { '<leader>rl', function() require('util.runner').rerun_last() end, desc = '[R]e-run [l]ast task' },
      { '<leader>rt', '<cmd>OverseerToggle! bottom<cr>', desc = '[R]un: toggle [t]ask list' },
      { '<leader>rs', '<cmd>OverseerShell<cr>', desc = '[R]un [s]hell command' },
      { '<leader>ra', '<cmd>OverseerTaskAction<cr>', desc = '[R]un: task [a]ction' },
      { '<leader>rc', function() require('util.toolchain').pick() end, desc = '[R]un: choose [c]ompiler / simulator' },
    },
    init = function()
      vim.api.nvim_create_user_command('Toolchain', function(cmd) require('util.toolchain').pick(cmd.args ~= '' and cmd.args or nil) end, {
        nargs = '?',
        complete = function() return require('util.toolchain').groups end,
        desc = 'Choose the compiler / simulator for <leader>rr: c, cpp or hdl (default: this buffer)',
      })
    end,
    opts_extend = { 'templates' },
    opts = {
      run = {},
      templates = {},
      task_list = {
        direction = 'bottom',
        min_height = 12,
        keymaps = { ['<C-h>'] = false, ['<C-j>'] = false, ['<C-k>'] = false, ['<C-l>'] = false }, -- tmux navigation
      },
    },
    config = function(_, opts)
      local overseer = require 'overseer'
      local setup = {}
      for key, value in pairs(opts) do
        if key ~= 'run' and key ~= 'templates' then setup[key] = value end
      end
      overseer.setup(setup)
      for _, template in ipairs(opts.templates) do
        overseer.register_template(template)
      end
      require('util.runner').setup(opts.run)
    end,
  },
}
