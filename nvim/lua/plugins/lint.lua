-- nvim-lint, only for tools without a language server. Language files add
-- `opts.linters_by_ft` and optional `opts.conditions[linter] = function(buf) -> bool`.
local function command(linter)
  local def = type(linter) == 'function' and linter() or linter
  if type(def) ~= 'table' then return nil end
  return type(def.cmd) == 'function' and def.cmd() or def.cmd
end

return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost', 'InsertLeave' },
    opts = { linters_by_ft = {}, conditions = {} },
    config = function(_, opts)
      local lint = require 'lint'
      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('user-lint', { clear = true }),
        callback = function(ev)
          local names = vim.tbl_filter(function(name)
            local cmd = command(lint.linters[name])
            local gate = opts.conditions[name]
            return cmd ~= nil and vim.fn.executable(cmd) == 1 and (gate == nil or gate(ev.buf))
          end, opts.linters_by_ft[vim.bo[ev.buf].filetype] or {})
          if #names > 0 then lint.try_lint(names) end
        end,
      })
    end,
  },
}
