local git = require("utils.git")
local picker = require("utils.picker")

local M = {}

local statusline = {
	"%<",
	"[%n]: ",
	'%{v:lua._statusline_component("git_branch")}',
	'%{%v:lua._statusline_component("statusline_diagnostic_highlight")%}',
	"%t",
	"%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''}",
	"%#StatusLine# ",
	'%{v:lua._statusline_component("git_status")}',
	"%h%m%r",
	"%=",
	"%-14.(%l,%c%V%) ",
	"%P",
}

local winbar = {
	"%<",
	"[%n]: ",
	'%{%v:lua._statusline_component("winbar_diagnostic_highlight")%}',
	"%f",
	"%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''}",
	"%#WinBar# ",
	'%{%v:lua._statusline_component("git_status")%}',
	"%h%m%r",
}

function M.update()
	vim.schedule(function()
		vim.o.statusline = table.concat(statusline, "")
		vim.o.winbar = table.concat(winbar, "")
	end)
end

function _G._statusline_component(component, ...)
	return M[component](...)
end

function M.git_branch()
	if git.branch.get():len() == 0 then return "" end
	return "[" .. git.branch.get() .. git.status.get() .. "] "
end

function M.git_status()
	local cur_buf_status = git.buf_status.get(vim.fn.bufnr())
	if cur_buf_status == nil then return "" end
	if cur_buf_status:len() == 0 then return "" end
	return "[" .. cur_buf_status .. "]"
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

	local hints = #vim.diagnostic.get(0, { severity = levels.HINT })
	if hints > 0 then
		return "H"
	end

	local infos = #vim.diagnostic.get(0, { severity = levels.INFO })
	if infos > 0 then
		return "i"
	end

	return ""
end

function M.statusline_diagnostic_highlight()
	if M.diagnostic_status() == "X" then return "%#StatusLineRed#" end
	if M.diagnostic_status() == "!" then return "%#StatusLineYellow#" end
	if M.diagnostic_status() == "H" then return "%#StatusLineBlue#" end
	if M.diagnostic_status() == "i" then return "%#StatusLineCyan#" end
	return ""
end

function M.winbar_diagnostic_highlight()
	if M.diagnostic_status() == "X" then return "%#WinBarRed#" end
	if M.diagnostic_status() == "!" then return "%#WinBarYellow#" end
	if M.diagnostic_status() == "H" then return "%#WinBarBlue#" end
	if M.diagnostic_status() == "i" then return "%#WinBarCyan#" end
	return ""
end

local group = vim.api.nvim_create_augroup("UnpluggedStatusLine", { clear = true })
vim.api.nvim_create_autocmd("User", {
	pattern = {
		unpack(vim.tbl_values(git.events)),
		picker.event,
	},
	group = group,
	callback = M.update,
})

M.update()
