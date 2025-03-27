_G.UnpluggedPrefix = "Unplugged"
vim.api.nvim_exec = vim.api.nvim_exec2

require("config.autocmds.comments")
require("config.autocmds.todo")
require("config.autocmds.transparency")
require("config.autocmds.gitsigns")
require("config.autocmds.lazyvim")
require("config.autocmds.templates")
