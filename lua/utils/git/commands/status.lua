---Gets git status summary
local M = {}
local common = require("utils.common")


-- OPTIONS =====================================================================

---@class GitStatusSigns
---@field behind string
---@field ahead string
---@field staged string
---@field unstaged string

---@class GitStatusCommandOpts
---@field event string Event to emit upon update completion
---@field signs GitStatusSigns

---Default opts. Ignored once `setup()` is called
---@type GitStatusCommandOpts
M.opts = {
	event = "UnpluggedGitStatus",
	signs = {
		behind = "↓",
		ahead = "↑",
		staged = "+",
		unstaged = "*",
	},
}


-- PRIVATE FIELDS ==============================================================

---Setup guard
local setup = false

---The name of the branch the current buffer is in
---@type string
local status = ""


-- PRIVATE METHODS =============================================================

---Updates branch tracking info
---@param branch_info string First line of the output of `git status -sb`
local function update_branch_tracking(branch_info)
	local tracking_info = branch_info:match("(%[.+)$")

	if tracking_info then
		local behind = tracking_info:find("behind")
		local ahead = tracking_info:find("ahead")

		status = status .. (behind and M.opts.signs.behind or "")
		status = status .. (ahead and M.opts.signs.ahead or "")
	end
end

---Checks if there are staged files
---@param files string[] Output of `git status -sb` as a list of strings
local function check_staged_files(files)
	for i = 2, #files do
		local staged_sign = files[i]:sub(1, 1)

		if staged_sign == "?" then return false end
		if staged_sign ~= " " then return true end
	end
	return false
end

---Checks if there are unstaged files
---@param files string[] Output of `git status -sb` as a list of strings
local function check_unstaged_files(files)
	for i = 2, #files do
		local unstaged_sign = files[i]:sub(2, 2)
		if unstaged_sign ~= " " then
			return true
		end
	end
	return false
end

---Update branch staging info
---@param git_status string[] Output of `git status -sb` as a list of strings
local function update_branch_staging(git_status)
	if #git_status < 2 then return end

	local has_staged = check_staged_files(git_status)
	local has_unstaged = check_unstaged_files(git_status)

	status = status .. (has_staged and M.opts.signs.staged or "")
	status = status .. (has_unstaged and M.opts.signs.unstaged or "")
end

local function update(obj)
	if obj.stdout == nil or obj.stdout:len() == 0 then
		status = ""
		return
	end

	status = ""

	local lines = vim.split(obj.stdout, "\n", { trimempty = true })
	update_branch_tracking(lines[1])
	update_branch_staging(lines)
end


-- PUBLIC METHODS ==============================================================

---Asynchronousely updates tracked status
---Emits the event set in `opts.event` upon completion
---Get the value using `get()`
function M.update()
	vim.system(
		{ "git", "status", "-sb" },
		common.get_cwd_cmd_opts(),
		function(obj)
			update(obj)
			common.exec_autocmds(M.opts.event)
		end
	)
end

---Gets the last tracked status
---Update the value using `update()`
function M.get()
	return status
end

---Set module options
---@param opts? GitBranchCommandOpts
function M.setup(opts)
	if setup == true then return end
	setup = true

	M.opts = vim.tbl_extend("force", M.opts, opts or {})
end


return M
