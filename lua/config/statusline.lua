local M = {}

local statusline = {
	"%<",
	"[%n]: ",
	'%{v:lua._statusline_component("git_branch")}',
	'%{%v:lua._statusline_component("statusline_diagnostic_highlight")%}',
	"%t",
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

local git_branch = ""
local git_branch_status = ""
local git_buf_statuses = {}

local git_group = vim.api.nvim_create_augroup("GitStatusLine", { clear = true })
local git_branch_events = { "BufEnter", "ShellCmdPost", "FocusGained" }
local git_file_events = vim.list_extend(git_branch_events, { "BufWritePost" })
local function get_git_cmd_opts()
	return { text = true, cwd = vim.fn.expand("%:p:h") }
end

vim.api.nvim_create_autocmd(git_branch_events, {
	group = git_group,
	callback = function()
		vim.system(
			{ "git", "branch", "--show-current" },
			get_git_cmd_opts(),
			function(obj)
				if obj.stdout == nil then
					git_branch = ""
					return
				end

				git_branch = obj.stdout:sub(1, -2)

				M.update()
			end
		)
	end
})

vim.api.nvim_create_autocmd(git_file_events, {
	group = git_group,
	callback = function(args)
		vim.system(
			{ "git", "status", "-s" },
			get_git_cmd_opts(),
			function(obj)
				if obj.stdout == nil then
					git_branch_status = ""
					return
				end

				git_branch_status = "*"
				M.update()
			end
		)

		vim.system(
			{ "git", "status", "-s", vim.fn.expand("%:p") },
			get_git_cmd_opts(),
			function(obj)
				if obj.stdout == nil then
					git_branch = ""
					return
				end

				local status = obj.stdout:sub(1, 2):gsub(" ", "-")
				git_buf_statuses[args.buf] = status

				M.update()
			end
		)
	end
})

function M.git_branch()
	if git_branch:len() == 0 then return "" end
	return "[" .. git_branch .. git_branch_status .. "] "
end

function M.git_status()
	local cur_buf_status = git_buf_statuses[vim.fn.bufnr()]
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
	return ""
end

function M.winbar_diagnostic_highlight()
	if M.diagnostic_status() == "X" then return "%#WinBarRed#" end
	if M.diagnostic_status() == "!" then return "%#WinBarYellow#" end
	return ""
end

M.update()
