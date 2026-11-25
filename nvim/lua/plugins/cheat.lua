-- :Cheat [app] shows one of the repo's cheatsheets (cheatsheets/<app>.md) in a float, rendered
-- by render-markdown. No app: this one (neovim). `q` or Esc closes it. `cheat <app>` is the shell version.

-- ~/.config/nvim links to <dotfiles>/nvim (through the release's `current` for a release install)
local function sheets_dir()
  local repo = vim.fs.dirname(vim.fn.resolve(vim.fn.stdpath 'config'))
  local dir = vim.fs.joinpath(repo, 'cheatsheets')
  if vim.fn.isdirectory(dir) == 0 and vim.env.DOTFILES then dir = vim.fs.joinpath(vim.env.DOTFILES, 'cheatsheets') end
  return dir
end

local function apps()
  return vim.tbl_map(function(path) return vim.fn.fnamemodify(path, ':t:r') end, vim.fn.glob(sheets_dir() .. '/*.md', false, true))
end

local ALIASES = { nvim = 'neovim', vim = 'neovim', zsh = 'shell', music = 'tamp' }

local function open(app)
  app = ALIASES[app] or app
  local path = vim.fs.joinpath(sheets_dir(), app .. '.md')
  if vim.fn.filereadable(path) == 0 then
    vim.notify(('No cheatsheet "%s". There are: %s'):format(app, table.concat(apps(), ', ')), vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(path))
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
  local width = math.min(120, math.floor(vim.o.columns * 0.9))
  local height = math.floor(vim.o.lines * 0.85)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    title = (' cheat: %s '):format(app),
    title_pos = 'center',
  })
  vim.wo[win].wrap = false
  vim.wo[win].conceallevel = 2
  vim.wo[win].cursorline = true
  for _, key in ipairs { 'q', '<Esc>' } do
    vim.keymap.set('n', key, function() vim.api.nvim_win_close(win, true) end, { buffer = buf, nowait = true, desc = 'Close the cheatsheet' })
  end
end

vim.api.nvim_create_user_command('Cheat', function(cmd) open(cmd.args ~= '' and cmd.args or 'neovim') end, {
  nargs = '?',
  complete = function(lead)
    return vim.tbl_filter(function(app) return vim.startswith(app, lead) end, apps())
  end,
  desc = 'Show a cheatsheet (default: neovim)',
})
vim.keymap.set('n', '<leader>sC', '<Cmd>Cheat<CR>', { desc = '[S]earch [C]heatsheet (:Cheat <app> for others)' })

return {}
