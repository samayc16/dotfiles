-- conform.nvim. Format-on-save policy:
--   * single-style languages (Python, Lua, Haskell) always;
--   * C-family and Swift only when the project has a style file, so other people's
--     code is never rewritten;
--   * shell and Verilog only on demand (<leader>f).
local clang_style = { '.clang-format', '_clang-format' }
local style_files = {
  c = clang_style,
  cpp = clang_style,
  objc = clang_style,
  objcpp = clang_style,
  cuda = clang_style,
  swift = { '.swift-format', '.swiftformat' },
  sh = false,
  bash = false,
  verilog = false,
  systemverilog = false,
}

local function format_on_save(buf)
  if vim.g.autoformat == false or vim.b[buf].autoformat == false then return nil end
  local markers = style_files[vim.bo[buf].filetype]
  if markers == false or (markers and not vim.fs.root(buf, markers)) then return nil end
  return { timeout_ms = 1500, lsp_format = 'fallback' }
end

local function toggle(scope)
  return function()
    local store = scope == 'buffer' and vim.b or vim.g
    store.autoformat = store.autoformat == false
    vim.notify(('Format on save (%s): %s'):format(scope, store.autoformat and 'on' or 'off'))
  end
end

return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      { '<leader>f', function() require('conform').format { async = true, lsp_format = 'fallback' } end, mode = { 'n', 'x' }, desc = '[F]ormat buffer' },
      { '<leader>tf', toggle 'global', desc = '[T]oggle [f]ormat on save' },
      { '<leader>tF', toggle 'buffer', desc = '[T]oggle [F]ormat on save (buffer)' },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = true,
      format_on_save = format_on_save,
      formatters_by_ft = {},
      formatters = {},
    },
  },
}
