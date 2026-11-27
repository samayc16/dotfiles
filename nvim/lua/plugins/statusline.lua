-- Statusline styled like the tmux bar right below it (tmux.conf "look: status bar"):
--
--   ( NORMAL)  main +2 ~1  󰈙 lua/plugins/statusline.lua ●   E1      󰑴 haskell-koans/03  lua_ls  ( 12:4  38%)
--
-- One pill for the mode (green like tmux's session pill; insert cyan, visual purple like
-- copy mode), a gray pill for the position (like tmux's clock), quiet text in between.
local c = { -- tmux.conf's palette (Monokai Pro "pro" filter)
  bar = '#221f22',
  surf = '#403e41',
  gray = '#727072',
  soft = '#939293',
  fg = '#fcfcfa',
  red = '#ff6188',
  orange = '#fc9867',
  yellow = '#ffd866',
  green = '#a9dc76',
  cyan = '#78dce8',
  purple = '#ab9df2',
}

local function theme()
  local quiet = { fg = c.soft, bg = c.bar }
  local function mode(color)
    return { a = { fg = c.bar, bg = color, gui = 'bold' }, b = quiet, c = { fg = c.fg, bg = c.bar }, x = quiet, y = quiet, z = { fg = c.fg, bg = c.surf } }
  end
  return {
    normal = mode(c.green),
    insert = mode(c.cyan),
    visual = mode(c.purple),
    replace = mode(c.red),
    command = mode(c.yellow),
    terminal = mode(c.orange),
    inactive = mode(c.surf),
  }
end

local function is_terminal() return vim.bo.buftype == 'terminal' end
local function not_terminal() return vim.bo.buftype ~= 'terminal' end

--- "track/slug" when this buffer is part of a `learn` exercise, read once per buffer.
local function exercise()
  if vim.b.learn_exercise == nil then
    local label = ''
    local root = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= '' and vim.fs.root(0, '.learn.json')
    if root then
      local ok, marker = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. '/.learn.json'), '\n'))
      if ok and type(marker) == 'table' and marker.slug then label = ('%s/%s'):format(marker.track or '?', marker.slug) end
    end
    vim.b.learn_exercise = label
  end
  return vim.b.learn_exercise
end

local function lsp_names()
  return table.concat(vim.tbl_map(function(client) return client.name end, vim.lsp.get_clients { bufnr = 0 }), ' ')
end

local function recording()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and ('REC @' .. reg) or ''
end

local function terminal_title()
  local title = vim.b.term_title or ''
  return title ~= '' and title or 'terminal'
end

local function file_label(name)
  if vim.bo.filetype == 'oil' then
    local ok, oil = pcall(require, 'oil')
    local dir = ok and oil.get_current_dir()
    return dir and vim.fn.fnamemodify(dir, ':~:.') or name
  end
  return name
end

local function git_diff()
  local status = vim.b.gitsigns_status_dict
  if status then return { added = status.added, modified = status.changed, removed = status.removed } end
end

return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local nerd = vim.g.have_nerd_font
      local left, right = nerd and '\u{e0b6}' or '', nerd and '\u{e0b4}' or ''
      local function icon(glyph, plain) return nerd and glyph or plain end
      return {
        options = {
          theme = theme(),
          globalstatus = true,
          component_separators = '',
          section_separators = { left = right, right = left }, -- each pill's outer caps
          disabled_filetypes = { statusline = { 'snacks_dashboard' } },
          icons_enabled = nerd,
        },
        sections = {
          lualine_a = { { 'mode', icon = icon('\u{e62b}', nil), separator = { left = left }, padding = { left = 0, right = 1 } } },
          lualine_b = {
            { function() return vim.b.gitsigns_head or '' end, icon = icon('\u{e725}', nil), color = { fg = c.soft } },
            {
              'diff',
              source = git_diff,
              symbols = { added = '+', modified = '~', removed = '-' },
              diff_color = { added = { fg = c.green }, modified = { fg = c.yellow }, removed = { fg = c.red } },
            },
          },
          lualine_c = {
            { terminal_title, cond = is_terminal, icon = icon('\u{f489}', nil) },
            { 'filetype', icon_only = true, cond = not_terminal, padding = { left = 1, right = 0 } },
            {
              'filename',
              path = 1,
              cond = not_terminal,
              fmt = file_label,
              symbols = { modified = '●', readonly = icon('\u{f023}', '[ro]'), unnamed = '[No Name]', newfile = '[New]' },
            },
            {
              'diagnostics',
              symbols = nerd and { error = '\u{f057} ', warn = '\u{f071} ', info = '\u{f05a} ', hint = '\u{f0335} ' } or nil,
              diagnostics_color = { error = { fg = c.red }, warn = { fg = c.orange }, info = { fg = c.cyan }, hint = { fg = c.purple } },
            },
          },
          lualine_x = {
            { recording, color = { fg = c.red, gui = 'bold' } },
            { exercise, icon = icon('\u{f0474}', 'learn'), color = { fg = c.purple } },
            { 'overseer', cond = function() return package.loaded.overseer ~= nil end },
            { lsp_names, icon = icon('\u{f085}', nil), color = { fg = c.gray } },
          },
          lualine_y = {},
          lualine_z = { { function() return '%l:%-2v %3p%%' end, separator = { right = right }, padding = { left = 1, right = 0 } } },
        },
      }
    end,
    config = function(_, opts)
      require('lualine').setup(opts)
      -- Redraw at once when a macro starts or stops, not on the next tick.
      vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
        group = vim.api.nvim_create_augroup('user-statusline', { clear = true }),
        callback = function()
          vim.schedule(function() require('lualine').refresh { place = { 'statusline' } } end)
        end,
      })
    end,
  },
}
