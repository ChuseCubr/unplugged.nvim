local M = {}

function _G._statusline_component(component, ...)
	return M[component](...)
end

function M.diagnostic_status()
	local mode = vim.api.nvim_get_mode().mode

	if mode == "t" then return "" end

	local levels = vim.diagnostic.severity
	local errors = #vim.diagnostic.get(0, { severity = levels.ERROR })
	if errors > 0 then
		return "X"
	end

	local warnings = #vim.diagnostic.get(0, { severity = levels.WARN })
	if warnings > 0 then
		return "!"
	end

	return ""
end

function M.statusline_diagnostic_highlight()
	if M.diagnostic_status() == "X" then return "%#StatusLineError#" end
	if M.diagnostic_status() == "!" then return "%#StatusLineWarning#" end
	return ""
end

function M.winbar_diagnostic_highlight()
	if M.diagnostic_status() == "X" then return "%#WinBarError#" end
	if M.diagnostic_status() == "!" then return "%#WinBarWarning#" end
	return ""
end

local statusline = {
	"%<",
	"[%n]: ",
	'%{%v:lua._statusline_component("statusline_diagnostic_highlight")%}',
	"%f",
	"%#StatusLine#",
	" ",
	"%h%m%r",
	"%=",
	"%-14.(%l,%c%V%)",
	" ",
	"%P",
}

local winbar = {
	"%<",
	"[%n]: ",
	'%{%v:lua._statusline_component("winbar_diagnostic_highlight")%}',
	"%f",
	"%#WinBar#"
}

vim.o.statusline = table.concat(statusline, "")
vim.o.winbar = table.concat(winbar, "")
