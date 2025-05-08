--- Populate loc/qf list with entries
local M = {}
local common = require("utils.common")
local git = require("utils.git")


-- OPTIONS =====================================================================

---@class PickerOpts
---@field loclist? boolean Use location list default to true

---@type PickerOpts
M.opts = {
	loclist = true
}

M.prefix = _G.UnpluggedPrefix .. "Picker"
M.event = M.prefix .. "Populate"
M.group = vim.api.nvim_create_augroup(M.prefix, { clear = true })


-- TYPES =======================================================================

---@class BufListItem
---@field bufnr integer
---@field text? string
---@field lnum? integer

---@class FileListItem
---@field filename string
---@field text? string
---@field lnum? integer

---@alias ListItem BufListItem | FileListItem

---@class PickerEvent
---@field what vim.fn.setqflist.what
---@field opts PickerOpts

-- PRIVATE FIELDS / METHODS ====================================================

---Setup guard
local setup = false

---Set loc or qf list
---@param what vim.fn.setqflist.what qflist `what` table
---@param opts? PickerOpts Use location list. Defaults to `true`
local function set_list(what, opts)
	opts = vim.tbl_extend("force", M.opts, opts or {})
	if opts.loclist then
		vim.fn.setloclist(0, {}, "r", what)
		vim.cmd("lopen")
	else
		vim.fn.setqflist({}, "r", what)
		vim.cmd("copen")
	end
end

---Get only valid unstaged signs for unstaged picker
---@param line string Line from `git status -s` output
local function get_unstaged_sign(line)
		local unstaged_sign = line:sub(2, 2)
		if unstaged_sign == " " or unstaged_sign == "D" then
			return nil
		end
		return unstaged_sign
end

---List unstaged files as loc/qflist out
---@param stdout string Stdout from `git status -s`
---@return ListItem[]
local function get_unstaged_files(stdout)
	if stdout == nil or stdout:len() == 0 then return {} end
	local lines = vim.split(stdout, "\n", { trimempty = true })

	return vim.tbl_map(
		function(line)
			local sign = get_unstaged_sign(line)
			if not sign then return end
			local status = sign == "?" and "[Added]" or "[Modified]"
			return {
				filename = vim.fn.fnamemodify(line:sub(4, -1), ":."),
				text = status
			}
		end,
		lines
	)
end

---@param type ChunkType
local function chunk_type_to_string(type)
	if type == git.chunk_types.ADDED then return "+" end
	if type == git.chunk_types.CHANGED then return "|" end
	return "-"
end


-- PUBLIC METHODS ==============================================================

---Pick from listed buffers
---@param opts PickerOpts
function M.bufs(opts)
	local ls = vim.api.nvim_exec("ls", { output = true })

	local listed_bufs = vim.tbl_map(
		function(ls_line)
			local buf = tonumber(ls_line:match("^%s*%d+"))
			local line = tonumber(ls_line:match("%d+$"))

			return { bufnr = buf, lnum = line }
		end,
		vim.split(ls.output, "\n")
	)

	set_list({ items = listed_bufs, title = "Open buffers" }, opts)
end

---Pick from git unstaged files
---@param opts PickerOpts
function M.unstaged_files(opts)
	vim.system(
		{ "git", "status", "-s" },
		{ text = true },
		function(obj)
			local files = get_unstaged_files(obj.stdout)
			common.exec_autocmds(M.event, {
				---@type PickerEvent
				data = {
					what = {
						items = files,
						title = "Unstaged files",
					},
					opts = opts
				}
			})
		end
	)
end

---Pick from git chunks in the current file
---@param opts PickerOpts
function M.unstaged_chunks(opts)
	local buf = vim.api.nvim_get_current_buf()
	local chunks = git.buf_diff.get(buf)
	local items = vim.tbl_map(
		---@param chunk GitChunk
		---@return ListItem
		function(chunk)
			local sign = chunk_type_to_string(chunk.type)
			local text = vim.api.nvim_buf_get_lines(buf, chunk.line - 1, chunk.line, false)[1]
			return {
				bufnr = buf,
				lnum = chunk.line,
				text = chunk.count .. sign .. " " .. vim.trim(text)
			}
		end,
		chunks
	)

	set_list({ items = items, title = "Unstaged git chunks" }, opts)
end

---Makes picker globally available (cmdline)
---and sets up autocmds for async `vim.system()` calls
function M.setup(opts)
	if setup then return end
	setup = true

	M.opts = vim.tbl_extend("force", M.opts, opts or {})

	vim.api.nvim_create_autocmd("User", {
		pattern = M.event,
		group = M.group,
		callback = function(args)
			---@type PickerEvent
			local data = args.data
			set_list(
				{
					items = data.what.items,
					title = data.what.title
				},
				data.opts
			)
		end
	})

	_G.Unplugged.Picker = M
end

return M
