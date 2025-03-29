---Gets git branch name
local M = {}
local common = require("utils.common")


-- OPTIONS =====================================================================

---@class GitBufDiffCommandOpts
---@field event string Event to emit upon update completion

---Default opts. Ignored once `setup()` is called
---@type GitBufDiffCommandOpts
M.opts = {
	event = "UnpluggedGitBufDiff",
}


-- TYPES =======================================================================

---Types of chunks
---@enum ChunkType
M.chunk_types = {
	ADDED = 1,
	REMOVED = 2,
	CHANGED = 3,
}

---@class GitChunk
---@field line integer
---@field count integer
---@field type ChunkType


-- PRIVATE FIELDS / METHODS ====================================================

---Setup guard
local setup = false

---A table<bufnr, GitChunk[]> of chunks per buffer
---@type GitChunk[][]
local chunks = {}

---Determine chunk type from diff removed and added info
---@param removed_info string Format "line[,count]" as in `-line[,count]` from `git diff`
---@param added_info string Format "line[,count]" as in `+line[,count]` from `git diff`
---@return ChunkType
local function infer_chunk_type(removed_info, added_info)
 local none_removed = vim.endswith(removed_info, ",0")
 local none_added = vim.endswith(added_info, ",0")

 if not (none_removed or none_added) then return M.chunk_types.CHANGED end
 if none_removed then return M.chunk_types.ADDED end
 return M.chunk_types.REMOVED
end

---Extract diff info from line output of `git diff`
---@param line string Diff info in the format `@@ -line[,count] +line[,count] @@`
---@return GitChunk?
local function extract_diff_info(line)
	local removed_info, added_info = line:match("^@@ %-(%S+) %+(%S+) @@")
	if not removed_info then return end

	local countstring = added_info:match(",(%d+)$") or "1"
	local count = tonumber(countstring)
	count = count == 0 and 1 or count -- should span at least 1 line
	local chunk_type = infer_chunk_type(removed_info, added_info)
	local linenr = tonumber(added_info:match("^%d+"))
	return { line = linenr, count = count, type = chunk_type }
end

---@param get_goto_chunk fun(buf_chunks: GitChunk[], line: integer): GitChunk Function that defines the chunk to jump to
local function goto(get_goto_chunk)
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local buf = vim.api.nvim_get_current_buf()
	local buf_chunks = M.get(buf)

	if vim.tbl_count(buf_chunks) == 0 then
		vim.notify("No more git chunks to move to", vim.log.levels.WARN)
		return
	end

	local goto_chunk = get_goto_chunk(buf_chunks, line)

	vim.cmd("norm m`")
	vim.cmd("" .. goto_chunk.line)
end

local function update(buf, obj)
	if obj.stdout == nil or obj.stdout:len() == 0 then
		chunks[buf] = {}
		return
	end

	local lines = vim.split(obj.stdout, "\n", { trimempty = true })

	---@type GitChunk[]
	local diffs = {}

	for _, line in ipairs(lines) do
		local diff = extract_diff_info(line)
		if diff then
			table.insert(
				diffs,
				extract_diff_info(line)
			)
		end
	end

	chunks[buf] = diffs
end


-- PUBLIC METHODS ==============================================================

---Asynchronousely updates tracked buf diffs
---Emits the event set in `opts.event` upon completion
---Get the current value using `get()`
---@param buf integer Buffer number
function M.update(buf)
	vim.system(
		{ "git", "diff", "-U0", common.get_buf_path(buf) },
		common.get_cwd_cmd_opts(),
		function(obj)
			update(buf, obj)
			common.exec_autocmds(M.opts.event, {
				data = { buf = buf },
			})
		end
	)
end

---Gets the last tracked buf diffs
---Update the value using `update()`
---@return GitChunk[]
function M.get(buf)
	return chunks[buf] or {}
end

---Navigates to the next git chunk within the current buffer
function M.goto_next()
	goto(function(buf_chunks, line)
		local next_chunk = vim.iter(buf_chunks):find(
			---@param chunk GitChunk
			function(chunk)
				return chunk.line > line
			end
		)

		if next_chunk == nil then
			next_chunk = buf_chunks[1]
		end

		return next_chunk
	end)
end

---Navigates to the previous git chunk within the current buffer
function M.goto_prev()
	goto(function(buf_chunks, line)
		local prev_chunk = vim.iter(buf_chunks):rev():find(
			---@param chunk GitChunk
			function(chunk)
				return chunk.line < line
			end
		)

		if prev_chunk == nil then
			prev_chunk = buf_chunks[#buf_chunks]
		end

		return prev_chunk
	end)
end

---Set module options
---@param opts? GitBranchCommandOpts
function M.setup(opts)
	if setup == true then return end
	setup = true

	M.opts = vim.tbl_extend("force", M.opts, opts or {})
end


return M
