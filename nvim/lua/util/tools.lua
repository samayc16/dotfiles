-- Locate command-line tools. On macOS several (clangd, clang-format, swift-format,
-- lldb-dap, sourcekit-lsp) live inside Xcode rather than on PATH; lookups here are
-- plain filesystem checks so they are cheap at spec-load time.
local M = {}

M.is_mac = vim.uv.os_uname().sysname == 'Darwin'
-- Headless runs (installer, CI, scripts) install synchronously; see scripts/bootstrap.lua.
M.headless = vim.list_contains(vim.v.argv, '--headless')

-- Newest first; the first one the compiler accepts wins.
M.cxx_stds = { 'c++26', 'c++2c', 'c++23', 'c++2b', 'c++20' }
M.c_stds = { 'c23', 'c2x', 'c17' }

local xcode_bin_dirs

local function xcode_dirs()
  if xcode_bin_dirs then return xcode_bin_dirs end
  local dev = vim.env.DEVELOPER_DIR or '/Applications/Xcode.app/Contents/Developer'
  if not vim.uv.fs_stat(dev) and vim.fn.executable 'xcode-select' == 1 then
    local out = vim.fn.system { 'xcode-select', '-p' }
    dev = vim.v.shell_error == 0 and vim.trim(out) or nil
  end
  xcode_bin_dirs = dev and { dev .. '/Toolchains/XcodeDefault.xctoolchain/usr/bin', dev .. '/usr/bin' } or {}
  return xcode_bin_dirs
end

---@param name string
---@return string? path inside Xcode (always nil off macOS)
function M.xcode(name)
  if not M.is_mac then return nil end
  for _, dir in ipairs(xcode_dirs()) do
    local path = dir .. '/' .. name
    if vim.fn.executable(path) == 1 then return path end
  end
end

--- PATH first, then Xcode; the bare name as a last resort.
---@param name string
---@return string
function M.find(name)
  local path = vim.fn.exepath(name)
  if path ~= '' then return path end
  return M.xcode(name) or name
end

---@param name string
function M.has(name) return vim.fn.executable(M.find(name)) == 1 end

---@param names string[]
---@return string first executable found, else the first name
function M.first(names)
  for _, name in ipairs(names) do
    if M.has(name) then return M.find(name) end
  end
  return names[1]
end

local std_cache = {}

--- Newest `-std=` value the compiler accepts for `lang` ('c' or 'c++'). Probed once.
---@return string?
function M.newest_std(compiler, lang, candidates)
  local key = compiler .. '\0' .. lang
  if std_cache[key] == nil then
    std_cache[key] = false
    for _, std in ipairs(candidates) do
      local probe = vim.system({ compiler, '-std=' .. std, '-x', lang, '-fsyntax-only', '-' }, { stdin = '' }):wait()
      if probe.code == 0 then
        std_cache[key] = std
        break
      end
    end
  end
  return std_cache[key] or nil
end

local run_cache = {}

--- Whether `compiler` builds a trivial `lang` program with `flags` that actually runs. For
--- sanitizers the runtime can be missing (a separate distro package) or broken: older ASan
--- crashes or hangs at random on kernels with high mmap ASLR entropy, hence the repeated runs.
function M.builds_and_runs(compiler, lang, flags)
  local key = table.concat({ compiler, lang, unpack(flags) }, '\0')
  if run_cache[key] == nil then
    local out = vim.fn.tempname()
    local cmd = vim.list_extend({ compiler, unpack(flags) }, { '-x', lang, '-', '-o', out })
    local ok = vim.system(cmd, { stdin = 'int main(void) { return 0; }\n', timeout = 60000 }):wait().code == 0
    for _ = 1, 20 do -- a broken runtime may also hang (endless DEADLYSIGNAL): timeout = failure
      ok = ok and vim.system({ out }, { timeout = 5000 }):wait().code == 0
    end
    vim.fn.delete(out)
    run_cache[key] = ok
  end
  return run_cache[key]
end

--- Sanitizer runtimes older than GCC 14 / LLVM 18 crash at random ("AddressSanitizer:DEADLYSIGNAL")
--- on kernels with 32 bits of mmap ASLR entropy (Linux 6.x defaults; GitHub's runners). A probe
--- can pass and the next run still crash, so on such a kernel only newer runtimes count.
function M.sanitizers_work(compiler, lang, flags)
  if vim.fn.has 'linux' == 1 then
    local bits = tonumber((vim.fn.readfile('/proc/sys/vm/mmap_rnd_bits', '', 1)[1] or ''):match '%d+')
    if bits and bits > 28 then
      local version = (vim.system({ compiler, '--version' }, { text = true }):wait().stdout or ''):match '[^\n]*'
      local major = tonumber(version:match 'version (%d+)' or version:match ' (%d+)%.%d+%.?%d*%s*$' or version:match '%) (%d+)%.' or '')
      local minimum = version:find 'clang' and 18 or 14
      if not major or major < minimum then return false end
    end
  end
  return M.builds_and_runs(compiler, lang, flags)
end

return M
