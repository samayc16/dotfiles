-- :Dojo: gamified Vim trainer that lives in this config (code: lua/dojo/).
-- No third-party dependencies; this "virtual" spec only registers the command.
return {
  {
    name = 'dojo',
    dir = vim.fn.stdpath 'config',
    virtual = true,
    lazy = true,
    init = function()
      vim.api.nvim_create_user_command('Dojo', function(o) require('dojo').command(o.fargs) end, {
        nargs = '*',
        complete = function(arglead) return require('dojo').complete(arglead) end,
        desc = 'Dojo: gamified Vim training (menu, next, stats, <id>)',
      })
    end,
  },
}
