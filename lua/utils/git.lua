local M = {}

---Setup guard
local setup = false

---The name of the branch the current buffer is in
---@type string
M.branch_name = ""

---The tracking and staging info of the branch the current buffer is in
---Legend:
---  ↓ - (Tracking) Local branch is behind
---  ↑ - (Tracking) Local branch is ahead
---  + - (Staging) Local branch has staged changes
---  * - (Staging) Local branch has unstaged changes
---@type string
M.branch_status = ""

---The tracking info of buffers
---The same format of `git status -s`
---@type string[]
M.buf_statuses = {}

---@class GitHelperOpts
---@field on_exit fun():any Function invoked after updating Git info

---@class AutocmdCallbackArgs
---@field buf integer Buffer number of the event

local function get_git_cmd_opts()
	return { text = true, cwd = vim.fn.expand("%:p:h") }
end

---Updates branch_name
---@param opts GitHelperOpts
local function update_branch_name(opts)
	vim.system(
		{ "git", "branch", "--show-current" },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil then
				M.branch_name = ""
				return
			end

			M.branch_name = obj.stdout:sub(1, -2)

			if opts ~= nil and opts.on_exit ~= nil then
				opts.on_exit()
			end
		end
	)
end

---Updates branch tracking info of `branch_status`
---@param branch_info string First line of the output of `git status -sb`
local function update_branch_tracking(branch_info)
	local tracking_idx = branch_info:find("%[")

	if tracking_idx then
		local tracking_info = branch_info:sub(tracking_idx, -1)
		local behind = tracking_info:find("behind")
		local ahead = tracking_info:find("ahead")

		M.branch_status = M.branch_status .. (behind and "↓" or "")
		M.branch_status = M.branch_status .. (ahead and "↑" or "")
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

	M.branch_status = M.branch_status .. (has_staged and "+" or "")
	M.branch_status = M.branch_status .. (has_unstaged and "*" or "")
end

---Updates branch_status
---@param args AutocmdCallbackArgs
---@param opts GitHelperOpts
local function update_branch_status(args, opts)
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

			if opts ~= nil and opts.on_exit ~= nil then
				opts.on_exit()
			end
		end
	)

	vim.system(
		{ "git", "status", "-s", vim.fn.expand("%:p") },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil then
				M.branch = ""
				return
			end

			local status = obj.stdout:sub(1, 2):gsub(" ", "-")
			M.buf_statuses[args.buf] = status

			if opts ~= nil and opts.on_exit ~= nil then
				opts.on_exit()
			end
		end
	)
end


---Create autocmds to update Git info automatically
---
---opts: a table containing the following fields:
---  - on_exit: A function invoked after Git info is updated
---
---@param opts GitHelperOpts
function M.setup(opts)
	if setup == true then return end
	setup = true

	local git_group = vim.api.nvim_create_augroup("UnpluggedGit", { clear = true })
	local git_branch_events = { "BufEnter", "ShellCmdPost", "FocusGained" }
	local git_file_events = vim.list_extend(git_branch_events, { "BufWritePost" })

	vim.api.nvim_create_autocmd(git_branch_events, {
		group = git_group,
		callback = function()
			update_branch_name(opts)
		end
	})

	vim.api.nvim_create_autocmd(git_file_events, {
		group = git_group,
		callback = function(args)
			update_branch_status(args, opts)
		end
	})
end

return M
