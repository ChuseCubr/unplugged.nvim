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

---Types of chunks
---@enum ChunkType
M.ChunkTypes = {
	ADDED = 1,
	REMOVED = 2,
	CHANGED = 3,
}

---@class GitChunk
---@field line integer
---@field count integer
---@field type ChunkType

---@type GitChunk[][]
M.buf_chunks = {}


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
opts.event_prefix = _G.UnpluggedPrefix .. "Git"


-- PRIVATE FIELDS

---Setup guard
local setup = false


-- PRIVATE METHODS / UTILS

---vim.system() opts for current file dir
local function get_git_cmd_opts()
	return { text = true, cwd = vim.fn.expand("%:p:h") }
end

---Expand and escape file name
---@param buf integer Buffer number
local function get_buf_path(buf)
	return vim.fn.fnameescape(vim.api.nvim_buf_get_name(buf))
end

---Autocmd invoker wrapper
---@param pattern string
---@param autocmd_opts? vim.api.keyset.exec_autocmds
local function exec_autocmd(pattern, autocmd_opts)
	local default_opts = {
		pattern = opts.event_prefix .. pattern
	}

	autocmd_opts = vim.tbl_extend("force", default_opts, autocmd_opts or {})

	vim.schedule(function()
		vim.api.nvim_exec_autocmds("User", autocmd_opts)
	end)
end

---Updates branch tracking info of `branch_status`
---@param branch_info string First line of the output of `git status -sb`
local function update_branch_tracking(branch_info)
	local tracking_info = branch_info:match("(%[.+)$")

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
	if #git_status < 2 then return end

	local staged_sign = git_status[2]:sub(1, 1)
	local has_staged = not (staged_sign == " " or staged_sign == "?")

	local unstaged_sign = git_status[#git_status]:sub(2, 2)
	local has_unstaged = unstaged_sign ~= " "

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
			if obj.stdout == nil or obj.stdout:len() == 0 then
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
		{ "git", "status", "-s", get_buf_path(buf) },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil or obj.stdout:len() == 0 then
				M.branch = ""
				return
			end

			local status = obj.stdout:sub(1, 2):gsub(" ", "-")
			M.buf_statuses[buf] = status

			exec_autocmd("BufStatus")
		end
	)
end

---@param removed_info string Format "line[,count]" as in `-line[,count]` from `git diff`
---@param added_info string Format "line[,count]" as in `+line[,count]` from `git diff`
---@return ChunkType
local function infer_chunk_type(removed_info, added_info)
 local none_removed = vim.endswith(removed_info, ",0")
 local none_added = vim.endswith(added_info, ",0")

 if not (none_removed or none_added) then return M.ChunkTypes.CHANGED end
 if none_removed then return M.ChunkTypes.ADDED end
 return M.ChunkTypes.REMOVED
end

function M.update_buf_diff(buf)
	vim.system(
		{ "git", "diff", "-U0", get_buf_path(buf) },
		get_git_cmd_opts(),
		function(obj)
			if obj.stdout == nil then
				M.branch = ""
				return
			end

			local lines = vim.split(obj.stdout, "\n", { trimempty = true })

			---@type GitChunk[]
			local diff_lines = vim.tbl_filter(function(line)
					return vim.startswith(line, "@@")
				end,
				lines
			)
			local chunks = vim.tbl_map(
				function(line)
					local removed_info, added_info = line:match("^@@ %-(%S+) %+(%S+) @@")
					if not removed_info then return end

					local countstring = added_info:match(",(%d+)$") or "1"
					local count = tonumber(countstring)
					count = count == 0 and 1 or count -- should span at least 1 line
					local chunk_type = infer_chunk_type(removed_info, added_info)
					local linenr = tonumber(added_info:match("^%d+"))

					return { line = linenr, count = count, type = chunk_type }
				end,
				diff_lines
			)

			M.buf_chunks[buf] = chunks
			exec_autocmd("BufDiff", {
				data = { buf = buf },
			})
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

			local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
			if ft == "netrw" then return end

			M.update_buf_status(args.buf)
			M.update_buf_diff(args.buf)
		end
	})
end

return M
