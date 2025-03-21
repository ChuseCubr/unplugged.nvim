local M = {}


-- PUBLIC FIELDS

---The name of the branch the current buffer is in
---@type string
M.branch_name = ""

---The tracking and staging info of the branch the current buffer is in
---@type string
M.branch_status = ""

---The tracking info of buffers
---The same format of `git status -s`
---@type string[]
M.buf_statuses = {}


-- SETTINGS

---Branch tracking/staging status signs
local opts = {}
opts.signs = {}
opts.signs.behind = "↓"
opts.signs.ahead = "↑"
opts.signs.staged = "+"
opts.signs.unstaged = "*"

---Events to trigger calling `git branch` commands
---@type string[]
opts.branch_events = { "BufEnter", "ShellCmdPost", "FocusGained" }

---Events to trigger calling `git status` and `git diff` commands
---@type string[]
opts.file_events = { "BufEnter", "ShellCmdPost", "FocusGained", "BufWritePost" }

---Prefix for events to be emitted after updating Git info
---@type string
opts.event_prefix = "UnpluggedGit"


-- PRIVATE FIELDS

---Setup guard
local setup = false


-- PRIVATE METHODS / UTILS

---vim.system() opts for current file dir
local function get_git_cmd_opts()
	return { text = true, cwd = vim.fn.expand("%:p:h") }
end

---Autocmd invoker wrapper
---@param pattern string
local function exec_autocmd(pattern)
	vim.schedule(function()
		vim.api.nvim_exec_autocmds("User", { pattern = opts.event_prefix .. pattern })
	end)
end

---Updates branch tracking info of `branch_status`
---@param branch_info string First line of the output of `git status -sb`
local function update_branch_tracking(branch_info)
	local _, _, tracking_info = branch_info:find("(%[.+)$")

	if tracking_info then
		local behind = tracking_info:find("behind")
		local ahead = tracking_info:find("ahead")

		M.branch_status = M.branch_status .. (behind and opts.signs.behind or "")
		M.branch_status = M.branch_status .. (ahead and opts.signs.ahead or "")
	end
end

---Update branch staging info of `M.branch_status`
---@param git_status string[] Output of `git status -sb` as a list of strings
local function update_branch_staging(git_status)
	local staged = vim.tbl_map(
		function(line)
			local staged_info = line:sub(1, 1)
			local is_staged = not (staged_info == "#" or staged_info == " " or staged_info == "?")
			return is_staged and true or nil
		end,
		git_status
	)
	local has_staged = not vim.tbl_isempty(staged)

	local unstaged = vim.tbl_map(
		function(line)
			local unstaged_info = line:sub(2, 2)
			local is_unstaged = not (unstaged_info == "#" or unstaged_info == " ")
			return is_unstaged and true or nil
		end,
		git_status
	)
	local has_unstaged = not vim.tbl_isempty(unstaged)

	M.branch_status = M.branch_status .. (has_staged and opts.signs.staged or "")
	M.branch_status = M.branch_status .. (has_unstaged and opts.signs.unstaged or "")
end


-- PUBLIC METHODS

---Updates `branch_name`
---Emits the `UnpluggedGitBranchName` event upon completion
function M.update_branch_name()
	vim.system(
		{ "git", "branch", "--show-current" },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil then
				M.branch_name = ""
				return
			end

			M.branch_name = obj.stdout:sub(1, -2)

			exec_autocmd("BranchName")
		end
	)
end

---Updates `branch_status`
---Emits the `UnpluggedGitBranchStatus` event upon completion
function M.update_branch_status()
	vim.system(
		{ "git", "status", "-sb" },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil or obj.stdout:len() == 0 then
				M.branch_status = ""
				return
			end

			M.branch_status = ""

			local lines = vim.split(obj.stdout, "\n", { trimempty = true })
			update_branch_tracking(lines[1])
			update_branch_staging(lines)

			exec_autocmd("BranchStatus")
		end
	)
end

---Updates `buf_statuses`
---Emits the `UnpluggedGitBufStatus` event upon completion
---@param buf integer Buffer number
function M.update_buf_status(buf)
	vim.system(
		{ "git", "status", "-s", vim.fn.expand("%:p") },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil then
				M.branch = ""
				return
			end

			local status = obj.stdout:sub(1, 2):gsub(" ", "-")
			M.buf_statuses[buf] = status

			exec_autocmd("BufStatus")
		end
	)
end

---Create autocmds to update Git info automatically
---Upon setup, autocmds will emit the following events:
---  - `UnpluggedGitBranchName`
---  - `UnpluggedGitBranchStatus`
---  - `UnpluggedGitBufStatus`
function M.setup()
	if setup == true then return end
	setup = true

	local git_group = vim.api.nvim_create_augroup("UnpluggedGit", { clear = true })

	vim.api.nvim_create_autocmd(opts.branch_events, {
		group = git_group,
		callback = function()
			M.update_branch_name()
		end
	})

	vim.api.nvim_create_autocmd(opts.file_events, {
		group = git_group,
		callback = function(args)
			M.update_branch_status()
			M.update_buf_status(args.buf)
		end
	})
end

return M
