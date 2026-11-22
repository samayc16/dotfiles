-- Open buffers as tabs along the top (tab *pages* are separate: :tabnew).
local function close(buf) Snacks.bufdelete { buf = buf, force = true } end -- keeps the window layout

local goto_keys = {}
for i = 1, 9 do
  goto_keys[i] = { '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<cr>', desc = 'Buffer ' .. i }
end

return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/snacks.nvim' },
    event = 'VeryLazy',
    opts = {
      options = {
        mode = 'buffers',
        diagnostics = 'nvim_lsp',
        show_close_icon = false,
        buffer_close_icon = '×',
        modified_icon = '●',
        close_command = close,
        right_mouse_command = close,
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)

      -- :q closes the current buffer, and only quits when it is the last one.
      vim.api.nvim_create_user_command('Q', function(args)
        if #vim.fn.getbufinfo { buflisted = 1 } <= 1 then
          vim.cmd('quit' .. (args.bang and '!' or ''))
        else
          Snacks.bufdelete { force = args.bang }
        end
      end, { bang = true, desc = 'Close buffer (or quit if last)' })
      -- Expand only a bare `q`/`q!`, so :qa, :quit, etc. are untouched.
      vim.cmd [[cnoreabbrev <expr> q  (getcmdtype() == ':' && getcmdline() ==# 'q')  ? 'Q'  : 'q']]
      vim.cmd [[cnoreabbrev <expr> q! (getcmdtype() == ':' && getcmdline() ==# 'q!') ? 'Q!' : 'q!']]
    end,
    keys = vim.list_extend({
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = '[B]uffer: [p]in' },
      { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = '[B]uffer: close [o]thers' },
      { '<leader>x', function() Snacks.bufdelete() end, desc = 'Close buffer' },
    }, goto_keys),
  },
}
