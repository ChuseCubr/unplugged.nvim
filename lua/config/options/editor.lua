-- Sync clipboard between OS and Neovim.
--	Remove this option if you want your OS clipboard to remain independent.
--	See `:help 'clipboard'`
-- vim.o.clipboard = "unnamedplus"

-- file opts
vim.o.autoread = true
vim.o.undofile = true
vim.o.updatetime = 250

-- search settings
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false

-- completion settings
vim.o.shellslash = true
vim.o.wildmenu = true
vim.o.wildoptions = "pum,tagfile,fuzzy"
vim.o.completeopt = "menu,menuone,popup,noinsert,noselect"
vim.o.wildignore = vim.o.wildignore .. ",*/node_modules/*,*/bin/*,*/obj/*,"

-- indent options
vim.o.breakindent = true
vim.o.expandtab = false
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- keymap behavior
vim.o.timeoutlen = 300

-- enable mouse
vim.o.mouse = "a"

-- wrap behavior
vim.o.linebreak = true

-- window behavior
vim.o.splitbelow = true
vim.o.splitright = true

-- netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1
vim.g.netrw_sizestyle = "H"
vim.g.netrw_sort_sequence = "^\\f\\+[\\/]"
vim.g.netrw_list_hide = vim.fn["netrw_gitignore#Hide"]() .. ",^\\.\\{1,2}\\f\\+[\\/]\\?"

-- qflist filter
vim.cmd.packadd("cfilter")
