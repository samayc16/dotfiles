-- Belt ladder. Each belt is one file in lua/dojo/challenges/<id>.lua.
-- `weight` multiplies the stars earned in that belt to give XP.
local M = {}

M.list = {
  { id = 'white', name = 'White', weight = 1, color = '#fcfcfa', theme = 'Moving around' },
  { id = 'yellow', name = 'Yellow', weight = 2, color = '#ffd866', theme = 'Precision jumps' },
  { id = 'orange', name = 'Orange', weight = 3, color = '#fc9867', theme = 'Operators and repeat' },
  { id = 'green', name = 'Green', weight = 4, color = '#a9dc76', theme = 'Text objects' },
  { id = 'blue', name = 'Blue', weight = 5, color = '#78dce8', theme = 'Search and substitute' },
  { id = 'purple', name = 'Purple', weight = 6, color = '#ab9df2', theme = 'Visual and block mode' },
  { id = 'brown', name = 'Brown', weight = 7, color = '#d4a373', theme = 'Registers, macros, ex' },
  -- "Your config" is a parallel track, so it opens early instead of last.
  { id = 'black', name = 'Black', weight = 8, color = '#ff6188', theme = 'Your config', unlock_xp = 20 },
}

M.by_id = {}
for index, belt in ipairs(M.list) do
  M.by_id[belt.id] = vim.tbl_extend('force', {}, belt, { index = index })
end

-- A belt unlocks once total XP reaches this share of all XP available in earlier belts.
M.UNLOCK_RATIO = 0.4

--- Highlight group name for a belt's colour (defined in dojo.ui).
function M.hl(belt_id) return 'DojoBelt' .. belt_id:sub(1, 1):upper() .. belt_id:sub(2) end

return M
