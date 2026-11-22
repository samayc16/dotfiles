-- Swift: sourcekit-lsp, swift-format/SwiftFormat, SwiftLint, and xcodebuild.nvim for
-- Xcode projects (<leader>X). Run :XcodebuildSetup once per project; Swift packages
-- need no setup.
local tools = require 'util.tools'
local q = vim.fn.shellescape

local function spm_root(buf) return vim.fs.root(buf or 0, { 'Package.swift' }) end

local function xcode_root(buf)
  return vim.fs.root(buf, function(name) return name:match '%.xcodeproj$' or name:match '%.xcworkspace$' end)
end

local function spm_task(subcommand)
  return {
    name = 'swift ' .. subcommand,
    condition = { callback = function() return spm_root() ~= nil end },
    builder = function() return { cmd = 'swift ' .. subcommand, cwd = spm_root() } end,
  }
end

local package_debug = {
  name = 'Debug Swift package executable',
  type = tools.is_mac and 'lldb-dap' or 'codelldb',
  request = 'launch',
  program = function()
    local root = spm_root() or vim.fn.getcwd()
    vim.system({ 'swift', 'build' }, { cwd = root }):wait()
    return vim.fn.input('Executable: ', root .. '/.build/debug/', 'file')
  end,
  cwd = '${workspaceFolder}',
}

return {
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'swift' } } },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        sourcekit = {
          mason = false, -- ships with Xcode / the Swift toolchain
          cmd = { tools.find 'sourcekit-lsp' },
          filetypes = { 'swift' }, -- C-family stays with clangd
        },
      },
      tools = tools.is_mac and { 'swiftlint', 'swiftformat' } or {},
    },
  },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        swift = function(buf) return vim.fs.root(buf, { '.swiftformat' }) and { 'swiftformat' } or { 'swift_format' } end,
      },
      formatters = { swift_format = { command = tools.find 'swift-format' } },
    },
  },

  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = { swift = { 'swiftlint' } },
      conditions = { swiftlint = function(buf) return vim.fs.root(buf, { '.swiftlint.yml' }) ~= nil end },
    },
  },

  {
    'stevearc/overseer.nvim',
    opts = {
      run = {
        swift = function(ctx)
          local root = spm_root(ctx.buf)
          if root then return { cmd = 'swift run', cwd = root } end
          if xcode_root(ctx.buf) then
            vim.notify('Xcode project: <leader>Xr builds and runs on the simulator.')
            return nil
          end
          return { cmd = 'swift ' .. q(ctx.file), cwd = ctx.dir }
        end,
      },
      templates = { spm_task 'build', spm_task 'run', spm_task 'test' },
    },
  },

  {
    'mfussenegger/nvim-dap',
    opts = {
      adapters = tools.is_mac and { ['lldb-dap'] = { type = 'executable', command = tools.find 'lldb-dap', name = 'lldb-dap' } } or {},
      configurations = { swift = { package_debug } },
    },
  },

  {
    'wojciech-kulik/xcodebuild.nvim',
    cond = tools.is_mac,
    cmd = { 'XcodebuildSetup', 'XcodebuildPicker' },
    ft = { 'swift', 'objc', 'objcpp' },
    dependencies = { 'nvim-telescope/telescope.nvim', 'MunifTanjim/nui.nvim', 'folke/snacks.nvim', 'mfussenegger/nvim-dap' },
    config = function()
      require('xcodebuild').setup {
        integrations = { xcode_build_server = { enabled = true }, pymobiledevice = { enabled = false } },
      }
      -- Its DAP setup replaces dap.configurations.swift; keep the package config too.
      require('xcodebuild.integrations.dap').setup()
      local dap = require 'dap'
      dap.configurations.swift = vim.list_extend({ package_debug }, dap.configurations.swift or {})
    end,
    keys = {
      { '<leader>XX', '<cmd>XcodebuildPicker<cr>', desc = 'Xcode: all actions' },
      { '<leader>XS', '<cmd>XcodebuildSetup<cr>', desc = 'Xcode: [S]etup project' },
      { '<leader>Xb', '<cmd>XcodebuildBuild<cr>', desc = 'Xcode: [b]uild' },
      { '<leader>Xr', '<cmd>XcodebuildBuildRun<cr>', desc = 'Xcode: build & [r]un' },
      { '<leader>Xd', '<cmd>XcodebuildBuildDebug<cr>', desc = 'Xcode: build & [d]ebug' },
      { '<leader>Xt', '<cmd>XcodebuildTest<cr>', desc = 'Xcode: [t]est' },
      { '<leader>XT', '<cmd>XcodebuildTestClass<cr>', desc = 'Xcode: [T]est class' },
      { '<leader>Xe', '<cmd>XcodebuildTestExplorerToggle<cr>', desc = 'Xcode: test [e]xplorer' },
      { '<leader>Xl', '<cmd>XcodebuildToggleLogs<cr>', desc = 'Xcode: [l]ogs' },
      { '<leader>Xs', '<cmd>XcodebuildSelectDevice<cr>', desc = 'Xcode: [s]elect device' },
      { '<leader>Xp', '<cmd>XcodebuildPreviewGenerateAndShow<cr>', desc = 'Xcode: SwiftUI [p]review' },
      { '<leader>Xc', '<cmd>XcodebuildToggleCodeCoverage<cr>', desc = 'Xcode: [c]overage' },
      { '<leader>Xa', '<cmd>XcodebuildCodeActions<cr>', desc = 'Xcode: code [a]ctions' },
      { '<leader>Xo', '<cmd>XcodebuildOpenInXcode<cr>', desc = 'Xcode: [o]pen in Xcode' },
    },
  },
}
