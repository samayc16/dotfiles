-- `<leader>rr`: run the current file as an overseer task.
--
-- Languages register builders via the overseer spec's `opts.run[filetype]`.
-- A builder gets { buf, file, dir, stem, root, out, outdir } and returns
-- { cmd = <shell string>, cwd? } or nil (after notifying why).
-- `out`/`outdir` are scratch paths for build artifacts, outside the project.
local M = {}

local builders = {}

function M.setup(defs) builders = vim.tbl_extend('force', {}, builders, defs or {}) end

function M.builder(ft) return builders[ft] end

function M.context(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  local outdir = vim.fn.stdpath 'cache' .. '/run'
  vim.fn.mkdir(outdir, 'p')
  local stem = vim.fn.fnamemodify(file, ':t:r')
  return {
    buf = buf,
    file = file,
    dir = vim.fs.dirname(file),
    stem = stem,
    root = vim.fs.root(buf, { '.git' }) or vim.fs.dirname(file),
    out = outdir .. '/' .. stem,
    outdir = outdir,
  }
end

---@param opts? { args?: string }
function M.run(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local builder = builders[ft]
  if not builder then
    vim.notify(('No runner for "%s". Try <leader>ro for project tasks.'):format(ft), vim.log.levels.WARN)
    return
  end
  if vim.api.nvim_buf_get_name(buf) == '' then
    vim.notify('Save the buffer to a file first.', vim.log.levels.WARN)
    return
  end
  -- Save when edited or never written (a brand-new file isn't on disk yet).
  if vim.bo[buf].modified or not vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf)) then vim.cmd 'silent write ++p' end

  local ctx = M.context(buf)
  local ok, spec = pcall(builder, ctx)
  if not ok then
    vim.notify('Runner failed: ' .. tostring(spec), vim.log.levels.ERROR)
    return
  end
  if not spec then return end

  local args = (opts.args and opts.args ~= '') and (' ' .. opts.args) or ''
  require('overseer')
    .new_task({
      name = 'run ' .. vim.fn.fnamemodify(ctx.file, ':t'),
      cmd = spec.cmd .. args,
      cwd = spec.cwd or ctx.dir,
      components = {
        'default',
        { 'unique', replace = true },
        { 'open_output', on_start = 'always', direction = 'dock', focus = false },
      },
    })
    :start()
end

function M.run_with_args()
  vim.ui.input({ prompt = 'Arguments: ' }, function(args)
    if args then M.run { args = args } end
  end)
end

function M.rerun_last()
  local overseer = require 'overseer'
  local tasks = overseer.list_tasks { sort = function(a, b) return a.id > b.id end }
  if #tasks == 0 then
    vim.notify('No tasks yet. <leader>rr runs the current file.')
    return
  end
  overseer.run_action(tasks[1], 'restart')
end

return M
