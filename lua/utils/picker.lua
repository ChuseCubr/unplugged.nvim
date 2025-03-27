--- Populate loc/qf list with entries
local M = {}
local common = require("utils.common")


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

---@class ListItem
---@field text? string
---@field bufnr? integer
---@field filename? string

---@class ListWhat
---@field items ListItem[]
---@field title string

---@class PickerEvent
---@field what ListWhat
---@field opts PickerOpts

-- PRIVATE FIELDS / METHODS ====================================================

---Setup guard
local setup = false

---Set loc or qf list
---@param what table qflist `what` table
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

	---@type ListItem[]
	local files = {}

	for _, line in ipairs(lines) do
		local sign = get_unstaged_sign(line)
		if sign then
			local status = sign == "?" and "[Added]" or "[Modified]"
			local entry = {
				filename = vim.fn.fnamemodify(line:sub(4, -1), ":."),
				text = status
			}
			table.insert(files, entry)
		end
	end

	return files
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

---Make picker globally available (cmdline)
---and sets up autocmds for async `vim.system()`
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

	_G.Picker = M
end

return M
