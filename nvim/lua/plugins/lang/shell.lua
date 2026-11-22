-- bash-language-server (with ShellCheck) + shfmt (manual: <leader>f).
local function interpreter(shell)
  return function(ctx) return { cmd = shell .. ' ' .. vim.fn.shellescape(ctx.file), cwd = ctx.dir } end
end

return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = { bashls = { mason = 'bash-language-server', filetypes = { 'sh', 'bash' } } },
      tools = { 'shellcheck', 'shfmt' },
    },
  },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = { sh = { 'shfmt' }, bash = { 'shfmt' } },
      -- Explicit flags make shfmt ignore .editorconfig.
      formatters = { shfmt = { prepend_args = { '-i', '2', '-ci' } } },
    },
  },

  { 'stevearc/overseer.nvim', opts = { run = { sh = interpreter 'sh', bash = interpreter 'bash', zsh = interpreter 'zsh' } } },
}
