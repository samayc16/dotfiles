-- C, C++, Objective-C: clangd (Xcode's on macOS), clang-format, codelldb.
-- Projects should provide compile_commands.json (CMake: -DCMAKE_EXPORT_COMPILE_COMMANDS=ON,
-- Make: `bear -- make`); standalone files use the newest standard the compiler accepts.
local tools = require 'util.tools'
local q = vim.fn.shellescape

local clangd = tools.xcode 'clangd' or tools.find 'clangd'
local cc = tools.first { 'clang', 'gcc' }
local cxx = tools.first { 'clang++', 'g++' }
local sanitize = '-g -O0 -Wall -Wextra -fsanitize=address,undefined'

local function std_for(ft)
  if ft == 'c' then return tools.newest_std(cc, 'c', tools.c_stds) or 'c17' end
  return tools.newest_std(cxx, 'c++', tools.cxx_stds) or 'c++20'
end

local function compile_and_run(compiler, ft)
  return function(ctx)
    local build = ('%s -std=%s %s %s -o %s'):format(q(compiler), std_for(ft), sanitize, q(ctx.file), q(ctx.out))
    return { cmd = build .. ' && ' .. q(ctx.out), cwd = ctx.dir }
  end
end

local function build_for_debug(compiler, ft)
  return function()
    local file = vim.api.nvim_buf_get_name(0)
    local out = vim.fn.stdpath 'cache' .. '/run/' .. vim.fn.fnamemodify(file, ':t:r') .. '-dbg'
    vim.fn.mkdir(vim.fs.dirname(out), 'p')
    local result = vim.system({ compiler, '-std=' .. std_for(ft), '-g', '-O0', file, '-o', out }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify('Build failed:\n' .. result.stderr, vim.log.levels.ERROR)
      return require('dap').ABORT
    end
    return out
  end
end

local function debug_configs(compiler, ft)
  return {
    { name = 'Debug current file', type = 'codelldb', request = 'launch', program = build_for_debug(compiler, ft), cwd = '${fileDirname}' },
    {
      name = 'Debug an executable…',
      type = 'codelldb',
      request = 'launch',
      program = function() return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file') end,
      args = function() return vim.split(vim.fn.input 'Arguments: ', ' ', { trimempty = true }) end,
      cwd = '${workspaceFolder}',
    },
  }
end

local function has_compile_db(root)
  return root and (vim.uv.fs_stat(root .. '/compile_commands.json') or vim.uv.fs_stat(root .. '/compile_flags.txt'))
end

return {
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'c', 'cpp', 'objc', 'cmake', 'doxygen', 'cuda' } } },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        clangd = {
          mason = not tools.is_mac and 'clangd' or false, -- Xcode's clangd knows the macOS SDK
          cmd = {
            clangd,
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          -- Fallback flags only apply without a compile database. One clangd serves a
          -- root, so a dir mixing standalone .c and .cpp files gets the first file's standard.
          before_init = function(params, config)
            if has_compile_db(config.root_dir) then return end
            local flags = { fallbackFlags = { '-std=' .. std_for(vim.bo.filetype) } }
            params.initializationOptions = vim.tbl_extend('force', params.initializationOptions or {}, flags)
          end,
          keys = { { '<leader>ch', '<cmd>LspClangdSwitchSourceHeader<cr>', '[C]ode: switch source/[h]eader' } },
        },
        neocmake = { mason = 'neocmakelsp' },
      },
      tools = tools.is_mac and { 'codelldb' } or { 'codelldb', 'clang-format' },
    },
  },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        objc = { 'clang_format' },
        objcpp = { 'clang_format' },
        cuda = { 'clang_format' },
      },
      formatters = { clang_format = { command = tools.find 'clang-format' } },
    },
  },

  { 'stevearc/overseer.nvim', opts = { run = { c = compile_and_run(cc, 'c'), cpp = compile_and_run(cxx, 'cpp') } } },

  {
    'mfussenegger/nvim-dap',
    opts = { configurations = { c = debug_configs(cc, 'c'), cpp = debug_configs(cxx, 'cpp') } },
  },
}
