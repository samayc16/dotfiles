-- Rust: rust-analyzer through rustaceanvim (runnables, debuggables via codelldb, macro
-- expansion, error explanations, docs.rs), clippy on save, inlay hints, crates.nvim in
-- Cargo.toml. The toolchain comes from rustup (install.d/rust.sh), not mason, so
-- rust-analyzer always matches the compiler. rustaceanvim owns the server: no lspconfig entry.
local q = vim.fn.shellescape

--- <leader>rr: `cargo run` inside a Cargo project, otherwise compile and run the single file.
local function run(ctx)
  local root = vim.fs.root(ctx.buf, 'Cargo.toml')
  if root then return { cmd = 'cargo run --quiet', cwd = root } end
  return { cmd = ('rustc --edition 2024 -g -o %s %s && %s'):format(q(ctx.out), q(ctx.file), q(ctx.out)), cwd = ctx.dir }
end

local function rust_lsp(...)
  local args = { ... }
  return function() vim.cmd.RustLsp(args) end
end

local function on_attach(_, buf)
  vim.lsp.inlay_hint.enable(true, { bufnr = buf }) -- inferred types and lifetimes; <leader>th hides them
  local function map(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = 'Rust: ' .. desc }) end
  map('<leader>ce', rust_lsp('explainError', 'current'), '[C]ode: [e]xplain this error (rustc --explain)')
  map('<leader>cE', rust_lsp('renderDiagnostic', 'current'), '[C]ode: full compiler [E]rror')
  map('<leader>cm', rust_lsp 'expandMacro', '[C]ode: expand [m]acro')
  map('<leader>cD', rust_lsp 'openDocs', '[C]ode: open [D]ocs.rs for the symbol')
  map('<leader>cp', rust_lsp 'parentModule', '[C]ode: [p]arent module')
  map('<leader>cC', rust_lsp 'openCargo', '[C]ode: open [C]argo.toml')
  map('<leader>rn', rust_lsp 'runnables', '[R]un: pick a test / binary / example (ru[n]nables)')
  map('<leader>dn', rust_lsp 'debuggables', '[D]ebug: pick a test / binary (debuggables)')
end

return {
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'rust', 'toml' } } },

  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false, -- a filetype plugin: it initialises itself on the first Rust buffer
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = on_attach,
          default_settings = {
            ['rust-analyzer'] = {
              check = { command = 'clippy' }, -- clippy lints on save, not just compile errors
              inlayHints = {
                lifetimeElisionHints = { enable = 'skip_trivial' },
                closureReturnTypeHints = { enable = 'with_block' },
              },
            },
          },
        },
      }
    end,
  },

  { -- Cargo.toml: latest versions, outdated markers, completion and upgrade actions
    'saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = { lsp = { enabled = true, actions = true, completion = true, hover = true } },
  },

  { 'stevearc/overseer.nvim', opts = { run = { rust = run } } },
}
