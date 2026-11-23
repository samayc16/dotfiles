-- nvim-treesitter `main` branch: needs the `tree-sitter` CLI and a C compiler to build
-- parsers. Language files extend `opts.ensure_installed`.
local headless = require('util.tools').headless

local function can_build()
  local cc = vim.fn.executable 'cc' == 1 or vim.fn.executable 'clang' == 1 or vim.fn.executable 'gcc' == 1
  return cc and vim.fn.executable 'tree-sitter' == 1
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- this branch does not support lazy-loading
    -- Blocks when headless: `nvim --headless +Lazy! restore +qa` would otherwise exit
    -- mid-build and leave stale tree-sitter lock files behind.
    build = function()
      local task = require('nvim-treesitter').update()
      if headless then task:wait(600000) end
    end,
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {
        'bash', 'diff', 'git_config', 'git_rebase', 'gitcommit', 'gitignore', 'html', 'json',
        'lua', 'luadoc', 'make', 'markdown', 'markdown_inline', 'printf', 'query', 'regex',
        'toml', 'vim', 'vimdoc', 'yaml',
      },
    },
    config = function(_, opts)
      local ts = require 'nvim-treesitter'
      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(lang) return not vim.list_contains(installed, lang) end, opts.ensure_installed)
      if #missing > 0 and can_build() and not headless then ts.install(missing) end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user-treesitter-start', { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then return end
          -- Only grammars that ship indent queries; others keep regular autoindent.
          if vim.treesitter.query.get(lang, 'indents') then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    opts = { max_lines = 3, multiline_threshold = 1 },
    keys = {
      { '[x', function() require('treesitter-context').go_to_context(vim.v.count1) end, desc = 'Jump to enclosing context' },
      { '<leader>tc', '<cmd>TSContext toggle<cr>', desc = '[T]oggle sticky [C]ontext' },
    },
  },
}
