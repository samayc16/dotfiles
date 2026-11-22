local M = {}

local sev = vim.diagnostic.severity
local virtual_text = { spacing = 2, source = 'if_many', prefix = '●' }

function M.setup()
  vim.diagnostic.config {
    severity_sort = true,
    update_in_insert = false,
    underline = { severity = { min = sev.WARN } },
    float = { border = 'rounded', source = 'if_many' },
    virtual_text = virtual_text,
    virtual_lines = false,
    jump = { float = true },
    signs = {
      text = {
        [sev.ERROR] = '\u{f057} ',
        [sev.WARN] = '\u{f071} ',
        [sev.INFO] = '\u{f05a} ',
        [sev.HINT] = '\u{f0335} ',
      },
    },
  }
end

--- Switch between end-of-line messages and full multi-line messages under the cursor.
function M.toggle_lines()
  local lines = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config {
    virtual_lines = lines and { current_line = true } or false,
    virtual_text = not lines and virtual_text or false,
  }
end

return M
