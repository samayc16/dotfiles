-- nvim-dap + dap-ui. Language files add `opts.adapters` and `opts.configurations`;
-- adapter binaries are installed through lspconfig's `opts.tools`.
local function dap(method)
  return function() require('dap')[method]() end
end

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
      { 'theHamsta/nvim-dap-virtual-text', opts = { virt_text_pos = 'eol' } },
      'jay-babu/mason-nvim-dap.nvim',
      'mason-org/mason.nvim',
    },
    keys = {
      { '<leader>db', dap 'toggle_breakpoint', desc = '[D]ebug: toggle [b]reakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Condition: ') end, desc = '[D]ebug: conditional [B]reakpoint' },
      { '<leader>dc', dap 'continue', desc = '[D]ebug: start / [c]ontinue' },
      { '<leader>do', dap 'step_over', desc = '[D]ebug: step [o]ver' },
      { '<leader>di', dap 'step_into', desc = '[D]ebug: step [i]nto' },
      { '<leader>dO', dap 'step_out', desc = '[D]ebug: step [O]ut' },
      { '<leader>dC', dap 'run_to_cursor', desc = '[D]ebug: run to [C]ursor' },
      { '<leader>dl', dap 'run_last', desc = '[D]ebug: run [l]ast' },
      { '<leader>dt', dap 'terminate', desc = '[D]ebug: [t]erminate' },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = '[D]ebug: [r]EPL' },
      { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug: toggle [u]I' },
      { '<leader>de', function() require('dapui').eval() end, mode = { 'n', 'x' }, desc = '[D]ebug: [e]valuate' },
      { '<F5>', dap 'continue', desc = 'Debug: continue' },
      { '<F10>', dap 'step_over', desc = 'Debug: step over' },
      { '<F11>', dap 'step_into', desc = 'Debug: step into' },
      { '<F12>', dap 'step_out', desc = 'Debug: step out' },
    },
    opts = { adapters = {}, configurations = {} },
    config = function(_, opts)
      local dap_mod, dapui = require 'dap', require 'dapui'

      -- Default setups for mason-installed adapters (codelldb); Python uses nvim-dap-python.
      local mason_dap = require 'mason-nvim-dap'
      mason_dap.setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = { function(config) mason_dap.default_setup(config) end, python = function() end },
      }
      for name, adapter in pairs(opts.adapters) do
        dap_mod.adapters[name] = adapter
      end
      for ft, configs in pairs(opts.configurations) do
        dap_mod.configurations[ft] = vim.list_extend(vim.deepcopy(configs), dap_mod.configurations[ft] or {})
      end

      dapui.setup()
      dap_mod.listeners.after.event_initialized['user-dapui'] = dapui.open
      dap_mod.listeners.before.event_terminated['user-dapui'] = dapui.close
      dap_mod.listeners.before.event_exited['user-dapui'] = dapui.close

      vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })
      local signs = {
        DapBreakpoint = { '\u{f111} ', 'DiagnosticError' },
        DapBreakpointCondition = { '\u{eaa7} ', 'DiagnosticWarn' },
        DapBreakpointRejected = { '\u{f05e} ', 'DiagnosticHint' },
        DapLogPoint = { '\u{f06ff} ', 'DiagnosticInfo' },
        DapStopped = { '\u{f0055} ', 'DiagnosticOk', 'DapStoppedLine' },
      }
      for name, sign in pairs(signs) do
        vim.fn.sign_define(name, { text = sign[1], texthl = sign[2], linehl = sign[3], numhl = sign[3] })
      end
    end,
  },
}
