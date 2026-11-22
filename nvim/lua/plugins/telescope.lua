return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          path_display = { 'filename_first' },
          layout_config = { prompt_position = 'top' },
          sorting_strategy = 'ascending',
        },
        extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
      }
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      local map = vim.keymap.set
      map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      map('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      map('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      map('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      map({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      map('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      map('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      map('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      map('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch recent files' })
      map('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      map('n', '<leader>sq', builtin.quickfix, { desc = '[S]earch [Q]uickfix' })
      map('n', '<leader>s"', builtin.registers, { desc = '[S]earch registers' })
      map('n', '<leader><leader>', builtin.buffers, { desc = 'Find open buffers' })
      map('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = 'Fuzzy search in buffer' })
      map('n', '<leader>s/', function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end, {
        desc = '[S]earch [/] in open files',
      })
      map('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim config' })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-telescope-lsp', { clear = true }),
        callback = function(ev)
          local function bmap(lhs, fn, desc) map('n', lhs, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc }) end
          bmap('grr', builtin.lsp_references, '[G]oto [R]eferences')
          bmap('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
          bmap('grd', builtin.lsp_definitions, '[G]oto [D]efinition')
          bmap('grt', builtin.lsp_type_definitions, '[G]oto [T]ype definition')
          bmap('gO', builtin.lsp_document_symbols, 'Document symbols')
          bmap('gW', builtin.lsp_dynamic_workspace_symbols, 'Workspace symbols')
        end,
      })
    end,
  },
}
