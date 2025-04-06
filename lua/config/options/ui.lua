-- better colors (on supported terms)
vim.o.termguicolors = true

-- Disable intro
vim.o.shortmess = vim.o.shortmess .. "I"

-- ui elements
vim.o.title = true
vim.o.laststatus = 3

-- cursor
vim.o.guicursor = "n-v-c-i:block"
vim.o.colorcolumn = "80"
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- gutter
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

-- white space characters
vim.o.showbreak = "↪"
vim.o.list = true
vim.opt.listchars:append({
	-- New line
	eol = "↲",

	-- Spaces
	space = "⋅",
	tab = "→ ",
	nbsp = "␣",

	-- Others
	extends = "»",
	precedes = "«",
})

-- cmdline height
-- not a fan of `messagesopt=wait:{n}`
vim.o.cmdheight = 2

-- custom colorscheme
vim.o.background = "dark"
vim.cmd.colorscheme("min-default")

-- gui
vim.o.guifont = "IosevkaTerm_NFM:h16"

-- neovide
vim.g.neovide_opacity = 0.9
