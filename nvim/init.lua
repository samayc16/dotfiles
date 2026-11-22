-- lua/config:       options, keymaps, autocmds, plugin bootstrap
-- lua/plugins:      one spec per concern; lua/plugins/lang: one per language
-- lua/util:         helpers shared by specs
-- snippets/:        custom VS Code-format snippets
-- scripts/:         headless bootstrap + smoke test (used by the installer)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'config.options'
require('config.diagnostics').setup()
require 'config.lazy'
require 'config.keymaps'
require 'config.autocmds'
