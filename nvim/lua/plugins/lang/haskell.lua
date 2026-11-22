-- Haskell: haskell-language-server (types on hover, hlint hints, code actions, eval) + fourmolu.
-- Toolchain comes from Homebrew (ghc, cabal-install, haskell-language-server, fourmolu, hlint),
-- not mason: HLS must be built for the exact GHC on PATH.
local q = vim.fn.shellescape

local project_markers = { 'hie.yaml', 'cabal.project', 'stack.yaml', 'package.yaml', '*.cabal' }

--- Directory holding a *.cabal file, if any (cabal tasks only make sense there).
local function cabal_root(buf)
  return vim.fs.root(buf or 0, function(name) return name:match '%.cabal$' ~= nil or name == 'cabal.project' end)
end

return {
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'haskell' } } },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        hls = {
          mason = false,
          cmd = { 'haskell-language-server-wrapper', '--lsp' },
          filetypes = { 'haskell', 'lhaskell', 'cabal' },
          -- nvim-lspconfig only starts HLS inside a cabal/stack project. Fall back to the
          -- file's directory so standalone scripts and learn koans get full LSP too
          -- (HLS then uses an implicit "direct GHC" cradle).
          root_dir = function(buf, on_dir)
            local file = vim.api.nvim_buf_get_name(buf)
            on_dir(vim.fs.root(buf, project_markers) or vim.fs.dirname(file))
          end,
          settings = {
            haskell = {
              formattingProvider = 'fourmolu',
              cabalFormattingProvider = 'none',
              plugin = {
                hlint = { globalOn = true }, -- style hints ("use map instead of foldr ...")
                eval = { globalOn = true }, -- `-- >>> expr` comments become runnable code lenses
              },
            },
          },
        },
      },
    },
  },

  { 'stevearc/conform.nvim', opts = { formatters_by_ft = { haskell = { 'fourmolu' } } } },

  {
    'stevearc/overseer.nvim',
    opts = {
      -- <leader>rr: run the current file as a script
      run = { haskell = function(ctx) return { cmd = 'runghc ' .. q(ctx.file), cwd = ctx.dir } end },
      templates = {
        {
          name = 'ghci: load current file',
          desc = 'Interactive REPL with this file loaded (focus the output and type)',
          condition = { filetype = { 'haskell' } },
          builder = function()
            local file = vim.api.nvim_buf_get_name(0)
            return { cmd = 'ghci ' .. q(file), cwd = vim.fs.dirname(file) }
          end,
        },
        {
          name = 'cabal build',
          condition = { filetype = { 'haskell', 'cabal' }, callback = function() return cabal_root() ~= nil end },
          builder = function() return { cmd = 'cabal build', cwd = cabal_root() } end,
        },
        {
          name = 'cabal run',
          condition = { filetype = { 'haskell', 'cabal' }, callback = function() return cabal_root() ~= nil end },
          builder = function() return { cmd = 'cabal run', cwd = cabal_root() } end,
        },
        {
          name = 'cabal test',
          condition = { filetype = { 'haskell', 'cabal' }, callback = function() return cabal_root() ~= nil end },
          builder = function() return { cmd = 'cabal test', cwd = cabal_root() } end,
        },
      },
    },
  },
}
