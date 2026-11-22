local opt = vim.opt

opt.number = true
opt.relativenumber = true -- counts for jumps like 5j
opt.signcolumn = 'yes'
opt.cursorline = true
opt.mouse = 'a'
opt.showmode = false
opt.laststatus = 3
opt.winborder = 'rounded'
opt.pumheight = 12
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = 'screen'
opt.confirm = true
opt.virtualedit = 'block'
opt.jumpoptions = 'stack,view'

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.shiftround = true
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'split'
opt.updatetime = 250
opt.timeoutlen = 300

opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.fillchars = { eob = ' ', fold = ' ', foldopen = '\u{f107}', foldclose = '\u{f105}', foldsep = ' ' }

opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldtext = ''
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Deferred: the clipboard provider is slow to initialise.
vim.schedule(function() opt.clipboard = 'unnamedplus' end)
