-- Verilog / SystemVerilog: slang-server (LSP), Verible (format, manual), Verilator or
-- Icarus for <leader>rr (choose with <leader>rc), Surfer (waves), slang-server.nvim
-- (<leader>v hierarchy views).
-- Per-project include dirs, file lists and UVM paths: .slang/server.json
-- (https://hudson-trading.github.io/slang-server/start/config/).
local q = vim.fn.shellescape
local hdl = { 'verilog', 'systemverilog' }

--- The module named after the file, else the last module declared.
local function top_module(buf, stem)
  local last
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local name = line:match '^%s*module%s+([%w_]+)'
    if name == stem then return name end
    last = name or last
  end
  return last
end

local simulators = {
  verilator = function(ctx, top)
    local mdir = ctx.outdir .. '/verilator-' .. top
    -- VCD, not FST: Homebrew's Verilator can't build FST support (missing lz4.h).
    local build = ('verilator --binary --timing --assert -j 0 -Wno-fatal --trace --top-module %s -Mdir %s %s'):format(top, q(mdir), q(ctx.file))
    return build .. ' && ' .. q(mdir .. '/V' .. top)
  end,
  iverilog = function(ctx, top)
    local out = ctx.outdir .. '/' .. top .. '.vvp'
    -- -n: $stop ends the run instead of opening vvp's interactive prompt.
    return ('iverilog -g2012 -Wall -s %s -o %s %s && vvp -n %s'):format(top, q(out), q(ctx.file), q(out))
  end,
}

local function simulate(ctx)
  local top = top_module(ctx.buf, ctx.stem)
  if not top then
    vim.notify('No `module` found in this file.', vim.log.levels.WARN)
    return nil
  end
  local simulator = require('util.toolchain').get(vim.bo[ctx.buf].filetype)
  if not simulators[simulator] then
    vim.notify('No simulator found: install Verilator or Icarus Verilog.', vim.log.levels.ERROR)
    return nil
  end
  return { cmd = simulators[simulator](ctx, top), cwd = ctx.dir }
end

local function current_file() return vim.api.nvim_buf_get_name(0) end

local templates = {
  {
    name = 'verilator: lint file',
    condition = { filetype = hdl },
    builder = function() return { cmd = 'verilator --lint-only -Wall --timing ' .. q(current_file()) } end,
  },
  {
    name = 'iverilog: simulate file',
    condition = { filetype = hdl },
    builder = function()
      local out = q(vim.fn.stdpath 'cache' .. '/run/iverilog.vvp')
      return { cmd = ('iverilog -g2012 -o %s %s && vvp %s'):format(out, q(current_file()), out) }
    end,
  },
  {
    name = 'surfer: open newest waveform',
    condition = { filetype = hdl },
    builder = function()
      local waves = vim.fn.globpath(vim.fn.getcwd(), '**/*.vcd', false, true)
      table.sort(waves, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
      if #waves == 0 then return { cmd = 'echo ' .. q 'No .vcd here: add $dumpfile/$dumpvars to the testbench.' } end
      return { cmd = 'surfer ' .. q(waves[1]) }
    end,
  },
}

return {
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'systemverilog' } } },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        -- slang-server needs glibc 2.27 and there's no older build: none on CentOS 7 (2.17)
        slang_server = {
          enabled = not require('util.tools').glibc_below(2, 27),
          mason = 'slang-server',
          cmd = { 'slang-server' },
          filetypes = hdl,
          root_markers = { '.slang', '.git' },
        },
      },
      tools = { 'verible' },
    },
  },

  { 'stevearc/conform.nvim', opts = { formatters_by_ft = { verilog = { 'verible' }, systemverilog = { 'verible' } } } },

  { 'stevearc/overseer.nvim', opts = { run = { verilog = simulate, systemverilog = simulate }, templates = templates } },

  {
    'hudson-trading/slang-server.nvim',
    lazy = false, -- defers its own setup until a Verilog buffer opens
    dependencies = { 'MunifTanjim/nui.nvim' },
    init = function() vim.treesitter.language.register('systemverilog', hdl) end,
    opts = { keymaps = { enable_defaults = true } },
  },
}
