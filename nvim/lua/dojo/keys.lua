-- Keystroke counting. Keys are counted the way VimGolf does: every typed key is 1,
-- including special keys like <Esc>, <CR> or <C-d>.
local M = {}

-- Pseudo-keys that are not real input and never count.
local IGNORED = {
  'ScrollWheel', 'MouseMove', 'Focus', 'Ignore', 'Paste', 'CursorHold', 'Cmd>', 'SNR', 'Plug>',
}

--- Count keys in readable key notation (as produced by `keytrans()`), e.g. 'ciwfoo<Esc>' → 7.
---@param notation string
---@return integer
function M.count(notation)
  local n, i = 0, 1
  while i <= #notation do
    local token = notation:match('^<[^<>]+>', i)
    if token then
      local ignored = false
      for _, pat in ipairs(IGNORED) do
        if token:find(pat, 1, true) then ignored = true end
      end
      if not ignored then n = n + 1 end
      i = i + #token
    else
      n = n + 1
      i = i + vim.str_utf_end(notation, i) + 1
    end
  end
  return n
end

--- Count keys in a raw typed string (internal byte representation from vim.on_key).
---@param typed string
---@return integer
function M.count_typed(typed) return M.count(vim.fn.keytrans(typed)) end

--- Count keys in an authored solution like 'ciw<C-r>0<Esc>' (accepts <leader>).
---@param solution string
---@return integer
function M.count_solution(solution)
  return M.count(vim.fn.keytrans(vim.api.nvim_replace_termcodes(solution, true, true, true)))
end

return M
