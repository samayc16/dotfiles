-- End-to-end check of every language with the real config:
--   nvim --headless -c 'luafile ~/.config/nvim/scripts/smoke.lua'      (SMOKE_ONLY=<lang> for one)
-- Per language: treesitter, LSP attach, a deliberate diagnostic, completion, and
-- <leader>rr (util.runner -> overseer) producing the expected output, once per installed
-- compiler / simulator (<leader>rc). Languages whose toolchain is missing are skipped.
-- Exit code 0 only if something ran and all passed.
local tools = require 'util.tools'
local toolchain = require 'util.toolchain'

local samples = {
  {
    lang = 'python',
    file = 'main.py',
    requires = { { 'python3' } },
    servers = { 'basedpyright', 'ruff' },
    setup = function(dir) -- a project venv basedpyright must pick up
      vim.fn.mkdir(dir .. '/.venv/bin', 'p')
      vim.uv.fs_symlink(vim.fn.exepath 'python3', dir .. '/.venv/bin/python')
    end,
    text = {
      'from dataclasses import dataclass',
      '@dataclass(frozen=True)',
      'class Point:',
      '    x: int',
      '    y: int',
      'square = lambda n: n * n',
      'p = Point(3, 4)',
      'bad: int = "oops"',
      'print(square(p.x) + square(p.y))',
    },
    expect = '25',
    extra = function(buf)
      local client = vim.lsp.get_clients({ bufnr = buf, name = 'basedpyright' })[1]
      local path = client and vim.tbl_get(client.settings, 'python', 'pythonPath') or ''
      local ok = path:match '/%.venv/bin/python$' ~= nil
      -- The temp dir's name includes the user name; print the full path only when it's wrong.
      return ok, 'venv=' .. (ok and '.venv/bin/python' or path)
    end,
  },
  {
    lang = 'c',
    file = 'main.c',
    requires = { { 'clang', 'gcc' } },
    servers = { 'clangd' },
    text = { '#include <stdio.h>', 'int main(void) { undefined_function(); return 0; }' },
    run_text = { '#include <stdbool.h>', '#include <stdio.h>', 'int main(void) { bool ok = true; printf("%d\\n", ok ? 42 : 0); return 0; }' },
    expect = '42',
  },
  {
    lang = 'cpp',
    file = 'main.cpp',
    requires = { { 'clang++', 'g++' } },
    needs = function() -- the sample uses C++26 placeholder variables (`_` twice)
      return tools.newest_std(toolchain.get 'cpp', 'c++', tools.cxx_stds) == 'c++26', 'compiler lacks C++26'
    end,
    servers = { 'clangd' },
    text = { '#include <iostream>', 'int main() { int broken = "nope"; std::cout << broken; }' },
    run_text = {
      '#include <iostream>',
      '#include <ranges>',
      '#include <vector>',
      'int main() {',
      '  std::vector v{3, 1, 2};',
      '  for (int x : v | std::views::reverse) std::cout << x << \'\\n\';',
      '  auto [a, _] = std::pair{1, 2};',
      '  auto [b, _] = std::pair{3, 4};',
      '  return a + b - 4;',
      '}',
    },
    expect = '2',
    extra = function() return vim.fn.exists ':LspClangdSwitchSourceHeader' == 2, '<leader>ch command' end,
  },
  {
    lang = 'swift',
    file = 'main.swift',
    requires = { { 'swift' }, { 'sourcekit-lsp' } },
    servers = { 'sourcekit' },
    text = { 'let bad: Int = "oops"', 'print(bad)' },
    run_text = { 'struct Point { let x: Int; let y: Int }', 'let square = { (n: Int) in n * n }', 'let p = Point(x: 3, y: 4)', 'print(square(p.x) + square(p.y))' },
    expect = '25',
  },
  {
    lang = 'systemverilog',
    file = 'counter.sv',
    requires = { { 'verilator', 'iverilog' } },
    servers = { 'slang_server' },
    text = { 'module counter (output logic [3:0] q);', '  assign q = undeclared_signal;', 'endmodule' },
    run_text = { 'module counter;', '  logic [3:0] q = 0;', '  initial begin', '    repeat (5) q++;', '    $display("q=%0d", q);', '    $finish;', '  end', 'endmodule' },
    expect = 'q=5',
  },
  {
    lang = 'haskell',
    file = 'Main.hs',
    requires = { { 'runghc' }, { 'haskell-language-server-wrapper', 'haskell-language-server' } },
    servers = { 'hls' },
    attach_timeout = 120000,
    text = { 'module Main where', 'bad :: Int', 'bad = "oops"', 'main :: IO ()', 'main = print bad' },
    run_text = { 'module Main where', 'main :: IO ()', 'main = print (sum (map (\\n -> n * n) [3, 4 :: Int]))' },
    expect = '25',
  },
  {
    lang = 'rust',
    file = 'src/main.rs',
    requires = { { 'cargo' }, { 'rust-analyzer' } },
    servers = { 'rust-analyzer' },
    attach_timeout = 120000,
    setup = function(dir)
      vim.fn.mkdir(dir .. '/src', 'p')
      vim.fn.writefile({ '[package]', 'name = "smoke"', 'version = "0.1.0"', 'edition = "2024"' }, dir .. '/Cargo.toml')
    end,
    text = { 'fn main() {', '    let bad: i32 = "oops";', '    println!("{bad}");', '}' },
    run_text = { 'fn main() {', '    let squares: i32 = [3, 4].iter().map(|n| n * n).sum();', '    println!("{squares}");', '}' },
    expect = '25',
  },
  {
    lang = 'lua',
    file = 'main.lua',
    requires = { { 'nvim' } },
    servers = { 'lua_ls' },
    text = { 'local t = { 1, 2, 3 }', 'undefined_global_fn()' },
    run_text = { 'local t = { 1, 2, 3 }', 'print(#t)' },
    expect = '3',
  },
  {
    lang = 'sh',
    file = 'main.sh',
    requires = { { 'bash' } },
    servers = { 'bashls' },
    text = { '#!/usr/bin/env bash', 'echo hello $1' }, -- SC2086
    run_text = { '#!/usr/bin/env bash', 'name=world', 'echo "hello $name"' },
    expect = 'hello world',
  },
}

-- One run per installed compiler / simulator: the sample pinned to each choice.
local GROUP = { c = 'c', cpp = 'cpp', systemverilog = 'hdl' }
samples = vim.iter(samples)
  :map(function(sample)
    local group = GROUP[sample.lang]
    local choices = group and toolchain.candidates(group) or {}
    if #choices == 0 then return { sample } end
    return vim.tbl_map(function(tool)
      local label = tool == choices[1] and sample.lang or sample.lang .. '+' .. tool
      return vim.tbl_extend('force', sample, { label = label, toolchain = { [group] = tool } })
    end, choices)
  end)
  :flatten()
  :totable()

local function log(fmt, ...) io.stdout:write(fmt:format(...) .. '\n') end

local function skip_reason(sample)
  for _, group in ipairs(sample.requires) do
    if not vim.iter(group):any(tools.has) then return 'missing ' .. table.concat(group, ' or ') end
  end
  if sample.needs then
    local ok, why = sample.needs()
    if not ok then return why end
  end
end

local function attached(buf, servers)
  local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients { bufnr = buf })
  return vim.iter(servers):all(function(s) return vim.list_contains(names, s) end)
end

--- Completion items at the start of line 2; retried because some servers answer
--- empty until their first parse finishes. Returns count, note.
local function completion_count(buf)
  local client = vim.lsp.get_clients({ bufnr = buf, method = 'textDocument/completion' })[1]
  if not client then return 0, 'no completion server' end
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  params.position = { line = 1, character = 0 }
  -- As editors send it: slang-server 0.3.1 hangs on Linux without a context (it
  -- dereferences the optional field).
  params.context = { triggerKind = vim.lsp.protocol.CompletionTriggerKind.Invoked }
  local count, note = 0, 'empty completion list'
  for _ = 1, 5 do
    local replies, err = vim.lsp.buf_request_sync(buf, 'textDocument/completion', params, 5000)
    if not replies then note = 'completion: ' .. tostring(err) end
    for _, reply in pairs(replies or {}) do
      if reply.err then note = 'completion: ' .. vim.inspect(reply.err) end
      local result = reply.result or {}
      count = count + #(result.items or result)
    end
    if count > 0 then break end
    vim.wait(1000)
  end
  if client:is_stopped() then note = 'server exited' end
  return count, note
end

--- The servers' recent LSP log lines (stderr, crashes), printed under a failure.
local function server_log(servers)
  local needles = vim.list_extend({}, servers)
  for _, name in ipairs(servers) do
    local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
    if type(cmd) == 'table' then table.insert(needles, vim.fs.basename(cmd[1])) end
  end
  local ok, lines = pcall(vim.fn.readfile, vim.lsp.log.get_filename())
  local hits = vim.tbl_filter(function(line)
    return vim.iter(needles):any(function(n) return line:find(n, 1, true) ~= nil end)
  end, ok and lines or {})
  return vim.list_slice(hits, math.max(1, #hits - 7))
end

--- Run the current buffer through <leader>rr's code path; returns ok, note.
local function run_file(expect)
  require('lazy').load { plugins = { 'overseer.nvim' } }
  local overseer = require 'overseer'
  local newest = function() return overseer.list_tasks({ sort = function(a, b) return a.id > b.id end })[1] end
  local previous = newest()
  require('util.runner').run()
  local task
  vim.wait(10000, function()
    task = newest()
    return task ~= nil and task ~= previous
  end, 100)
  if not task or task == previous then return false, 'no task started' end
  vim.wait(300000, function() return task:is_complete() end, 200)
  local bufnr = task:get_bufnr()
  local output = bufnr and table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n') or ''
  return task.status == 'SUCCESS' and output:find(expect, 1, true) ~= nil, task.status .. ': ' .. output:sub(1, 300)
end

local function check(sample)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir .. '/.git', 'p')
  if sample.setup then sample.setup(dir) end
  local path = dir .. '/' .. sample.file
  vim.fn.writefile(sample.text, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()

  local res = { treesitter = vim.treesitter.highlighter.active[buf] ~= nil }
  res.lsp = vim.wait(sample.attach_timeout or 30000, function() return attached(buf, sample.servers) end, 200)
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '' }) -- some servers only lint on change
  vim.wait(20000, function() return #vim.diagnostic.get(buf) > 0 end, 200)
  res.diagnostics = #vim.diagnostic.get(buf)
  local completion_note
  res.completion, completion_note = completion_count(buf)
  res.extra, res.note = true, ''
  if sample.extra then res.extra, res.note = sample.extra(buf) end
  if res.completion == 0 then res.note = res.note .. ' ' .. completion_note end

  vim.fn.writefile(sample.run_text or sample.text, path)
  vim.cmd 'edit!'
  local run_note
  res.run, run_note = run_file(sample.expect)
  if not res.run then res.note = res.note .. ' ' .. run_note end

  res.ok = res.treesitter and res.lsp and res.diagnostics > 0 and res.completion > 0 and res.extra and res.run
  return res
end

local only = vim.env.SMOKE_ONLY
local ran, failed, skipped = 0, 0, 0
for _, sample in ipairs(samples) do
  if not only or only == sample.lang then
    vim.g.toolchain = sample.toolchain
    local name = sample.label or sample.lang
    local why = skip_reason(sample)
    if why then
      skipped = skipped + 1
      log('%-22s SKIP  %s', name, why)
    else
      ran = ran + 1
      local ok, res = pcall(check, sample)
      if not ok then res = { ok = false, note = tostring(res) } end
      if not res.ok then failed = failed + 1 end
      log('%-22s %s  ts=%s lsp=%s diags=%s completion=%s run=%s %s', name, res.ok and 'PASS' or 'FAIL', tostring(res.treesitter),
        tostring(res.lsp), tostring(res.diagnostics), tostring(res.completion), tostring(res.run), res.note or '')
      if not res.ok then
        for _, line in ipairs(server_log(sample.servers)) do log('    %s', line:sub(1, 400)) end
      end
    end
    vim.g.toolchain = nil
    vim.cmd 'silent! %bwipeout!'
  end
end

log('\n%d passed, %d failed, %d skipped', ran - failed, failed, skipped)
vim.cmd((ran > 0 and failed == 0) and 'qa!' or 'cq!')
