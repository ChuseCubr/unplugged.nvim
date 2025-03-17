require("config.options.statusline")

-- better colors (on supported terms)
vim.o.termguicolors = true

-- Disable intro
vim.o.shortmess = vim.o.shortmess .. "I"

-- ui elements
vim.o.title = true
vim.o.laststatus = 3
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
	trail = "⋅",
	tab = "→ ",
	nbsp = "␣",

	-- Others
	extends = "»",
	precedes = "«",
})

-- diagnostics
local signs = { Error = "X ", Warn = "! ", Hint = "H ", Info = "i " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- custom colorscheme
vim.o.background = "dark"
vim.cmd.colorscheme("min-default")

-- gui
vim.o.guifont = "IosevkaTerm_NFM:h16"
