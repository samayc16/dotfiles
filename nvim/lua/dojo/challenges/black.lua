-- Black belt: YOUR config. Surround, comments, save, move lines, diagnostics, folds,
-- oil, telescope, buffers, LSP, format, run, debug, trouble, undotree, git hunks.
-- Challenges that need a plugin/LSP list it in `requires`; the menu shows what's missing.

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile(lines, path)
end

local function tab_has_ft(ft)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == ft then return true end
  end
  return false
end

local function current_name_ends(suffix)
  local name = vim.api.nvim_buf_get_name(0)
  return name:sub(-#suffix) == suffix
end

local function inject_diagnostics(ctx, specs)
  local ns = vim.api.nvim_create_namespace 'dojo-diagnostics'
  local diags = {}
  for _, d in ipairs(specs) do
    local line = vim.api.nvim_buf_get_lines(ctx.buf, d.row - 1, d.row, false)[1] or ''
    local col = (line:find(d.match, 1, true) or 1) - 1
    table.insert(diags, { lnum = d.row - 1, col = col, end_col = col + #d.match, message = d.msg, severity = vim.diagnostic.severity.WARN, source = 'dojo' })
  end
  vim.diagnostic.set(ns, ctx.buf, diags)
end

local function git(ctx, args)
  local cmd = { 'git', '-C', ctx.dir, '-c', 'user.name=dojo', '-c', 'user.email=dojo@example.invalid', '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null' }
  local res = vim.system(vim.list_extend(cmd, args), { text = true }):wait()
  assert(res.code == 0, 'git ' .. table.concat(args, ' ') .. ' failed: ' .. (res.stderr or ''))
end

local function luarc(ctx) write(ctx.dir .. '/.luarc.json', { '{ "runtime": { "version": "LuaJIT" } }' }) end

local SLUG_LUA = {
  'local function slugify(s)',
  "  return (s:lower():gsub('%s+', '-'))",
  'end',
  '',
  'local function make_url(title)',
  "  return '/posts/' .. slugify(title)",
  'end',
  '',
  "print(make_url('Hello World'))",
}

local LOADER_LUA = {
  'local function parse(line)',
  "  local key, value = line:match('^(%w+)=(.*)$')",
  '  return key, valu',
  'end',
  '',
  'local function load(path)',
  '  local out = {}',
  '  for line in io.lines(path) do',
  '    local k, v = prase(line)',
  '    out[k] = v',
  '  end',
  '  return ot',
  'end',
}

local LOADER_DIAGS = {
  { row = 3, match = 'valu', msg = 'Undefined global `valu`.' },
  { row = 9, match = 'prase', msg = 'Undefined global `prase`.' },
  { row = 12, match = 'ot', msg = 'Undefined global `ot`.' },
}

return {
  -- ── Editing comforts ────────────────────────────────────────────────
  {
    id = 'k-01',
    title = 'Surround: add',
    goal = 'Wrap `message` in double quotes.',
    teaches = { 'sa{motion}{char}', 'saiw"' },
    ext = 'lua',
    start = { 'print(message)' },
    from = { row = 1, match = 'message' },
    target = { 'print("message")' },
    requires = { 'mini.surround' },
    par = 5,
    solution = 'saiw"',
    hint = 'sa = surround add, then a motion/text object (iw), then the character.',
  },
  {
    id = 'k-02',
    title = 'Surround: delete',
    goal = 'Remove the redundant inner parentheses.',
    teaches = { 'sd{char}' },
    ext = 'c',
    start = { 'if ((ready)) {' },
    from = { row = 1, match = 'ready' },
    target = { 'if (ready) {' },
    requires = { 'mini.surround' },
    par = 3,
    solution = 'sd)',
    hint = 'sd) deletes the nearest surrounding parens.',
  },
  {
    id = 'k-03',
    title = 'Surround: replace',
    goal = "Switch 'guest' to double quotes.",
    teaches = { 'sr{old}{new}' },
    ext = 'py',
    start = { "name = 'guest'" },
    from = { row = 1, match = 'guest' },
    target = { 'name = "guest"' },
    requires = { 'mini.surround' },
    par = 4,
    solution = [[sr'"]],
    hint = 'sr = surround replace: old character, then new.',
  },
  {
    id = 'k-04',
    title = 'Comment out',
    goal = 'Comment out the debug and trace lines.',
    teaches = { 'gc{motion}', 'gcc', 'gcap' },
    ext = 'py',
    start = { 'x = compute()', 'debug(x)', 'trace(x)', 'print(x)' },
    from = { row = 2 },
    target = { 'x = compute()', '# debug(x)', '# trace(x)', 'print(x)' },
    par = 3,
    solution = 'gcj',
    hint = 'gc is an operator: gcj comments this line and the next. gcc does one line.',
  },
  {
    id = 'k-05',
    title = 'Save it',
    goal = 'Set DEBUG to False and save, without typing :w.',
    teaches = { '<C-s>' },
    ext = 'py',
    start = { 'DEBUG = True', 'PORT = 8080' },
    check = function(ctx)
      if vim.bo[ctx.buf].modified then return false, 'unsaved changes' end
      local disk = vim.fn.readfile(ctx.file)
      return disk[1] == 'DEBUG = False' and disk[2] == 'PORT = 8080'
    end,
    requires = { 'map:n:<C-s>' },
    par = 11,
    solution = 'wwciwFalse<C-s>',
    hint = '<C-s> saves in normal, insert and visual mode in this config (and leaves insert mode).',
  },
  {
    id = 'k-06',
    title = 'Move lines',
    goal = 'Move `import os` to the top using visual mode.',
    teaches = { 'V', 'K', 'J' },
    ext = 'py',
    start = { 'import sys', 'import json', 'import os' },
    from = { row = 3 },
    target = { 'import os', 'import sys', 'import json' },
    requires = { 'map:x:K' },
    par = 4,
    solution = 'VKK<Esc>',
    hint = 'In this config J/K in visual mode move the selection down/up.',
  },
  -- ── Navigation ──────────────────────────────────────────────────────
  {
    id = 'k-07',
    title = 'Diagnostic hops',
    goal = 'Jump to the third problem (`ot`).',
    teaches = { ']d', '[d', '{count}]d' },
    ext = 'lua',
    start = LOADER_LUA,
    on_open = function(ctx) inject_diagnostics(ctx, LOADER_DIAGS) end,
    cursor = { row = 12, match = 'ot' },
    par = 3,
    solution = '3]d',
    hint = ']d / [d jump between diagnostics and take a count. <C-w>d shows the message.',
  },
  {
    id = 'k-08',
    title = 'Fold it',
    goal = 'Fold away the `slugify` function.',
    teaches = { 'zc', 'zo', 'za', 'zM', 'zR' },
    ext = 'lua',
    start = SLUG_LUA,
    from = { row = 2 },
    opts = { foldmethod = 'expr', foldexpr = 'v:lua.vim.treesitter.foldexpr()', foldlevel = 99, foldenable = true },
    check = function(ctx)
      return vim.api.nvim_win_call(ctx.win, function() return vim.fn.foldclosed(1) ~= -1 end)
    end,
    par = 2,
    solution = 'zc',
    hint = 'Folds come from treesitter. zc closes, zo opens, za toggles, zM/zR close/open all.',
  },
  {
    id = 'k-09',
    title = 'Rename a file with oil',
    goal = 'Fix the typo in the file name: helpres.py → helpers.py.',
    teaches = { '-', 'oil: edit names', ':w' },
    ext = 'py',
    filename = 'main.py',
    start = { 'import helpers', '', 'helpers.run()' },
    setup = function(ctx) write(ctx.dir .. '/helpres.py', { 'def run():', '    print("hi")' }) end,
    steps = { 'Press - to open the folder as a buffer.', 'Edit the name like text.', ':w to apply.' },
    check = function(ctx) return vim.uv.fs_stat(ctx.dir .. '/helpers.py') ~= nil and vim.uv.fs_stat(ctx.dir .. '/helpres.py') == nil end,
    requires = { 'oil' },
    replay = false,
    drive = { '-', 'kciwhelpers<Esc>', ':w', '<CR>' }, -- selftest pacing for oil's async listing
    par = 16,
    solution = '-kciwhelpers<Esc>:w<CR>',
    hint = 'In oil, the directory IS a buffer: rename by editing text, delete with dd, then :w.',
  },
  {
    id = 'k-10',
    title = 'Find a file',
    goal = 'Open src/models.py with the file finder.',
    teaches = { '<leader>sf' },
    ext = 'md',
    filename = 'NOTES.md',
    start = { '# Project notes', '', 'The models live somewhere under src/.' },
    setup = function(ctx)
      for _, f in ipairs { 'src/routes.py', 'src/models.py', 'src/views.py', 'tests/test_models.py' } do
        write(ctx.dir .. '/' .. f, { '# ' .. f })
      end
    end,
    check = function() return current_name_ends '/src/models.py' end,
    requires = { 'telescope', 'map:n:<leader>sf' },
    replay = false,
    par = 11,
    solution = '<leader>sfsrc/mod<CR>',
    hint = 'Fuzzy finding matches path pieces: "src/mod" beats "models" here.',
  },
  {
    id = 'k-11',
    title = 'Grep the project',
    goal = 'Find the line marked BUG and land on it.',
    teaches = { '<leader>sg' },
    ext = 'md',
    filename = 'NOTES.md',
    start = { '# Bug hunt', '', 'Somebody left a BUG marker in src/.' },
    setup = function(ctx)
      write(ctx.dir .. '/src/api.py', { 'def handler(req):', '    return req' })
      write(ctx.dir .. '/src/worker.py', {
        'import time',
        '',
        'def work(items):',
        '    out = []',
        '    for i in range(len(items)):',
        '        out.append(items[i])',
        '    # BUG: off by one when items is empty',
        '    return out',
      })
    end,
    check = function() return current_name_ends '/src/worker.py' and vim.api.nvim_win_get_cursor(0)[1] == 7 end,
    requires = { 'telescope', 'exe:rg', 'map:n:<leader>sg' },
    replay = false,
    par = 7,
    solution = '<leader>sgBUG<CR>',
    hint = 'Live grep searches file contents as you type.',
  },
  {
    id = 'k-12',
    title = 'Switch buffers',
    goal = 'Switch to the open util.lua buffer with the buffer picker.',
    teaches = { '<leader><leader>' },
    ext = 'lua',
    filename = 'main.lua',
    start = { "local util = require('util')", 'util.run()' },
    setup = function(ctx)
      write(ctx.dir .. '/config.lua', { 'return {}' })
      write(ctx.dir .. '/util.lua', { 'return { run = function() end }' })
    end,
    on_open = function(ctx)
      vim.cmd.badd(vim.fn.fnameescape(ctx.dir .. '/config.lua'))
      vim.cmd.badd(vim.fn.fnameescape(ctx.dir .. '/util.lua'))
    end,
    check = function() return current_name_ends '/util.lua' end,
    requires = { 'telescope', 'map:n:<leader><leader>' },
    replay = false,
    par = 7,
    solution = '<leader><leader>util<CR>',
    hint = '<leader><leader> lists open buffers; type a few letters and Enter.',
  },
  {
    id = 'k-13',
    title = 'Next buffer',
    goal = 'Cycle to the next buffer in the tab strip.',
    teaches = { '<S-l>', '<S-h>', '<leader>x' },
    ext = 'lua',
    filename = 'first.lua',
    start = { "print('first')" },
    setup = function(ctx) write(ctx.dir .. '/next.lua', { "print('next')" }) end,
    on_open = function(ctx) vim.cmd.badd(vim.fn.fnameescape(ctx.dir .. '/next.lua')) end,
    check = function() return current_name_ends '/next.lua' end,
    requires = { 'bufferline', 'map:n:<S-l>' },
    replay = false,
    par = 1,
    solution = '<S-l>',
    hint = 'Shift-l / Shift-h cycle through buffers; <leader>x closes one.',
  },
  -- ── LSP ─────────────────────────────────────────────────────────────
  {
    id = 'k-14',
    title = 'Hover docs',
    goal = 'Show the hover documentation for `slugify`.',
    teaches = { 'K' },
    ext = 'lua',
    start = SLUG_LUA,
    setup = luarc,
    from = { row = 6, match = 'slugify' },
    check = function()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_win_get_config(win).relative ~= '' and vim.bo[buf].filetype == 'markdown' then return true end
      end
      return false
    end,
    requires = { 'exe:lua-language-server' },
    replay = false,
    par = 1,
    solution = 'K',
    hint = 'K shows hover docs (press K again to jump into the float). Wait for the LSP to attach.',
  },
  {
    id = 'k-15',
    title = 'Go to definition and back',
    goal = 'Jump to where `slugify` is defined, then come back.',
    teaches = { 'grd', '<C-o>', '<C-i>' },
    ext = 'lua',
    start = SLUG_LUA,
    setup = luarc,
    from = { row = 6, match = 'slugify' },
    steps = { 'grd jumps to the definition.', '<C-o> jumps back (the jumplist), <C-i> forward again.' },
    check = function(ctx)
      if vim.api.nvim_get_current_buf() ~= ctx.buf then return false end
      local row = vim.api.nvim_win_get_cursor(0)[1]
      if row == 1 then ctx.state.visited = true end
      return ctx.state.visited == true and row == 6
    end,
    requires = { 'exe:lua-language-server' },
    replay = false,
    drive = { 'grd', '<C-o>' }, -- selftest pacing: wait for the LSP jump
    par = 4,
    solution = 'grd<C-o>',
    hint = 'grd = go to definition. <C-o> walks back through the jumplist.',
  },
  {
    id = 'k-16',
    title = 'Rename a symbol',
    goal = 'Rename `count` to `total` everywhere with the LSP.',
    teaches = { 'grn', '<leader>cr' },
    ext = 'lua',
    start = { 'local count = 0', 'for i = 1, 3 do', '  count = count + i', 'end', 'print(count)' },
    setup = luarc,
    from = { row = 1, match = 'count' },
    target = { 'local total = 0', 'for i = 1, 3 do', '  total = total + i', 'end', 'print(total)' },
    requires = { 'exe:lua-language-server' },
    replay = false,
    drive = { 'grn', '<C-u>total', '<CR>' }, -- selftest pacing: wait for the rename prompt
    par = 10,
    solution = 'grn<C-u>total<CR>',
    hint = 'The rename prompt is prefilled with the old name: <C-u> clears it.',
  },
  {
    id = 'k-17',
    title = 'Format the buffer',
    goal = 'Fix the formatting with the formatter (ruff).',
    teaches = { '<leader>f', '<leader>tf' },
    ext = 'py',
    start = { 'def add(a,b):', '  return a+b' },
    target = { 'def add(a, b):', '    return a + b' },
    requires = { 'conform', 'exe:ruff', 'map:n:<leader>f' },
    replay = false,
    par = 2,
    solution = '<leader>f',
    hint = '<leader>f formats; <leader>tf toggles format-on-save.',
  },
  -- ── Tools ───────────────────────────────────────────────────────────
  {
    id = 'k-18',
    title = 'Run this file',
    goal = 'Run hello.py without leaving the editor.',
    teaches = { '<leader>rr', '<leader>rt', '<leader>rl' },
    ext = 'py',
    filename = 'hello.py',
    start = { 'name = "dojo"', 'print(f"hello from {name}")' },
    check = function()
      local ok, overseer = pcall(require, 'overseer')
      if not ok then return false end
      for _, task in ipairs(overseer.list_tasks()) do
        if task.name:find('hello.py', 1, true) then return true end
      end
      return false
    end,
    requires = { 'overseer', 'exe:python3', 'map:n:<leader>rr' },
    replay = false,
    par = 3,
    solution = '<leader>rr',
    hint = '<leader>rr runs the current file; <leader>rt shows the task list, <leader>rl reruns.',
  },
  {
    id = 'k-19',
    title = 'Set a breakpoint',
    goal = 'Put a breakpoint on line 4 (`total += x`).',
    teaches = { '{n}G', '<leader>db', '<leader>dc' },
    ext = 'py',
    start = { 'def total(xs):', '    total = 0', '    for x in xs:', '        total += x', '    return total', '', 'print(total([1, 2, 3]))' },
    check = function(ctx)
      local ok, bps = pcall(require, 'dap.breakpoints')
      if not ok then return false end
      for _, bp in ipairs(bps.get(ctx.buf)[ctx.buf] or {}) do
        if bp.line == 4 then return true end
      end
      return false
    end,
    requires = { 'dap', 'map:n:<leader>db' },
    replay = false,
    par = 5,
    solution = '4G<leader>db',
    hint = '<leader>db toggles a breakpoint; <leader>dc starts/continues the debugger.',
  },
  {
    id = 'k-20',
    title = 'Problems list',
    goal = 'Open the diagnostics list for this buffer.',
    teaches = { '<leader>q', '<leader>Q' },
    ext = 'lua',
    start = LOADER_LUA,
    on_open = function(ctx) inject_diagnostics(ctx, LOADER_DIAGS) end,
    check = function() return tab_has_ft 'trouble' end,
    requires = { 'trouble', 'map:n:<leader>q' },
    replay = false,
    par = 2,
    solution = '<leader>q',
    hint = '<leader>q = this buffer, <leader>Q = whole workspace.',
  },
  {
    id = 'k-21',
    title = 'Undo tree',
    goal = 'Open the visual undo history.',
    teaches = { '<leader>ut' },
    ext = 'py',
    start = { 'answer = 42' },
    check = function() return tab_has_ft 'undotree' end,
    requires = { 'cmd:UndotreeToggle', 'map:n:<leader>ut' },
    replay = false,
    par = 3,
    solution = '<leader>ut',
    hint = 'Undo history is a tree: undotree lets you visit branches u/<C-r> cannot reach.',
  },
  {
    id = 'k-22',
    title = 'Reset a git hunk',
    goal = 'Throw away the uncommitted change on line 2.',
    teaches = { '<leader>hr', '<leader>hp', ']c' },
    ext = 'py',
    start = { 'def ping():', '    return "pong?!"' },
    setup = function(ctx)
      write(ctx.file, { 'def ping():', '    return "pong"' })
      git(ctx, { 'init', '-q' })
      git(ctx, { 'add', '.' })
      git(ctx, { 'commit', '-q', '-m', 'init' })
    end,
    from = { row = 2 },
    target = { 'def ping():', '    return "pong"' },
    requires = { 'gitsigns', 'exe:git' },
    replay = false,
    par = 3,
    solution = '<leader>hr',
    hint = '<leader>hp previews a hunk, <leader>hr resets it, <leader>hs stages it.',
  },
}
