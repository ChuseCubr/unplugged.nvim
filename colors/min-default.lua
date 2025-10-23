local prefix = vim.o.background == "dark" and "Light" or "Dark"
local inverted_prefix = vim.o.background == "dark" and "Dark" or "Light"

local function get_color(color)
	if color == "LightMagenta" then
		return "#ff80ff"
	end

	return "Nvim" .. color
end

local function set_accent(group, fg)
	fg = "Light" .. fg
	local bg = "DarkGray2"
	vim.api.nvim_set_hl(0, group, { fg = get_color(bg), bg = get_color(fg) })
end

local function set_color(group, fg)
	if vim.o.background == "dark" then
		fg = "Light" .. fg
		vim.api.nvim_set_hl(0, group, { fg = get_color(fg) })
		return
	end

	set_accent(group, fg)
end

local function base_color(groups)
	local opts = { fg = get_color(prefix .. "Gray2"), bold = vim.o.background == "light" and true or false }

	if type(groups) == "string" then
		vim.api.nvim_set_hl(0, groups, opts)
		return
	end

	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

local function dimmed_color(groups)
	local opts = { fg = get_color(prefix .. "Gray4") }

	if type(groups) == "string" then
		vim.api.nvim_set_hl(0, groups, opts)
		return
	end

	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

-- statusline and winbar
local function set_statusline_color(name, color)
	color = "Light" .. color
	local fg = vim.o.background == "dark" and "DarkGrey3" or color
	local bg = vim.o.background == "dark" and color or "DarkGrey3"

	vim.api.nvim_set_hl(0, name, { fg = get_color(fg), bg = get_color(bg) })
end

local function set_winbar_color(name, color)
	color = "Light" .. color
	local fg = vim.o.background == "dark" and color or "DarkGrey4"
	local bg = vim.o.background == "dark" and "DarkGrey1" or color

	vim.api.nvim_set_hl(0, name, { fg = get_color(fg), bg = get_color(bg) })
end

local function setup()
	vim.cmd("hi clear")
	vim.cmd("syntax reset")
	vim.g.colors_name = "min-default"

	-- resets
	local base = {
		"Function",
		"Identifier",
		"Label",
		"Macro",
		"Tag",
		"@attribute.builtin",
		"@constant.builtin",
		"@function.builtin",
		"@tag.builtin",
		"@variable",
		"@variable.builtin",
		"@variable.parameter.builtin",
		"MiniStarterItem",
	}

	base_color(base)

	-- dim
	local dimmed = {
		"Keyword",
		"Statement",
		"Delimiter",
		"Operator",
		"Special",
		"Structure",
		"Type",
		"ComplMatchIns",
	}

	dimmed_color(dimmed)

	-- highlights
	-- comments
	set_color("Comment", "Yellow")
	set_accent("Todo", "Magenta")
	set_accent("Fixme", "Red")

	-- declarations
	set_color("@lsp.typemod.namespace.declaration", "Blue")
	set_color("@lsp.typemod.enum.declaration", "Blue")
	set_color("@lsp.typemod.type.declaration", "Blue")
	set_color("@lsp.typemod.interface.declaration", "Blue")
	set_color("@lsp.typemod.class.declaration", "Blue")
	set_color("@lsp.typemod.method.declaration", "Blue")
	set_color("@lsp.typemod.macro.declaration", "Blue")
	set_color("@lsp.typemod.function.declaration", "Blue")
	set_color("@lsp.typemod.variable.declaration", "Blue")
	set_color("@lsp.typemod.parameter.declaration", "Blue")

	-- strings
	set_color("String", "Green")
	set_color("Character", "Green")
	set_color("SpecialChar", "Green")

	-- literals
	set_color("Number", "Magenta")
	set_color("Float", "Magenta")
	set_color("Boolean", "Magenta")

	-- diagnostics
	set_color("DiagnosticError", "Red")
	set_color("DiagnosticWarn", "Yellow")
	set_color("DiagnosticInfo", "Cyan")

	-- git
	set_color("Added", "Green")
	set_color("Removed", "Red")
	set_color("Changed", "Yellow")

	-- specific buffer types
	-- netrw
	set_color("netrwDir", "Cyan")
	-- tsx html
	set_color("tsxRegion", "Blue")

	-- statusline
	set_statusline_color("StatusLineGreen", "Green")
	set_statusline_color("StatusLineYellow", "Yellow")
	set_statusline_color("StatusLineRed", "Red")
	set_statusline_color("StatusLineBlue", "Blue")
	set_statusline_color("StatusLineCyan", "Cyan")

	-- winbar
	set_winbar_color("WinBarGreen", "Green")
	set_winbar_color("WinBarYellow", "Yellow")
	set_winbar_color("WinBarRed", "Red")
	set_winbar_color("WinBarBlue", "Blue")
	set_winbar_color("WinBarCyan", "Cyan")

	-- manual sets
	-- other parenthesis
	vim.api.nvim_set_hl(0, "MatchParen", { fg = get_color(prefix .. "Cyan"), bg = get_color(inverted_prefix .. "Blue") })

	-- neovide term colors
	vim.g.terminal_color_0 = get_color(prefix .. "Gray4")
	vim.g.terminal_color_1 = get_color(prefix .. "Red")
	vim.g.terminal_color_2 = get_color(prefix .. "Green")
	vim.g.terminal_color_3 = get_color(prefix .. "Yellow")
	vim.g.terminal_color_4 = get_color(prefix .. "Blue")
	vim.g.terminal_color_5 = get_color(prefix .. "Magenta")
	vim.g.terminal_color_6 = get_color(prefix .. "Cyan")
	vim.g.terminal_color_7 = get_color(prefix .. "Gray2")

	vim.g.terminal_color_8 = vim.g.terminal_color_0
	vim.g.terminal_color_9 = vim.g.terminal_color_1
	vim.g.terminal_color_10 = vim.g.terminal_color_2
	vim.g.terminal_color_11 = vim.g.terminal_color_3
	vim.g.terminal_color_12 = vim.g.terminal_color_4
	vim.g.terminal_color_13 = vim.g.terminal_color_5
	vim.g.terminal_color_14 = vim.g.terminal_color_6
	vim.g.terminal_color_15 = vim.g.terminal_color_7

	-- custom matches
	_G.MinDefaultMatches = {}

	-- fix leading white space in tsxRegion in light mode
	if vim.o.background == "light" then
		vim.api.nvim_set_hl(0, "Dimmed", { bg = get_color("LightGray2") })
		table.insert(_G.MinDefaultMatches, vim.fn.matchadd("Dimmed", "^\\s*"))
	end

	-- clean up matches on theme change
	local augroup = vim.api.nvim_create_augroup("MinDefaultMatches", { clear = true })
	vim.api.nvim_create_autocmd("Colorscheme", {
		group = augroup,
		once = true,
		callback = function()
			for _, match in ipairs(_G.MinDefaultMatches) do
				vim.fn.delete(match)
			end
		end,
	})
end

vim.schedule(setup)
