--- Gets git branch name
local M = {}
local common = require("utils.common")


-- OPTIONS =====================================================================

---@class GitBufStatusCommandOpts
---@field event string Event to emit upon update completion

---Default opts. Ignored once `setup()` is called
---@type GitBufStatusCommandOpts
M.opts = {
	event = "UnpluggedGitBufStatus",
}


-- PRIVATE FIELDS ==============================================================

---Setup guard
local setup = false

---The statuses of buffers, where the index is the buffer number
---@type string[]
local statuses = {}

local function update(buf, obj)
	if obj.stdout == nil or obj.stdout:len() == 0 then
		statuses[buf] = nil
		return
	end

	local status = obj.stdout:sub(1, 2):gsub(" ", "-")
	statuses[buf] = status
end


-- PUBLIC METHODS ==============================================================

---Asynchronousely updates tracked buffer status
---Emits the event set in `opts.event` upon completion
---Get the current value using `get()`
---@param buf integer Buffer number
function M.update(buf)
	vim.system(
		{ "git", "status", "-s", common.get_buf_path(buf) },
		common.get_cwd_cmd_opts(),
		function(obj)
			update(buf, obj)
			common.exec_autocmds(M.opts.event)
		end
	)
end

---Gets the last tracked buffer status
---Update the value using `update()`
function M.get(buf)
	return statuses[buf]
end

---Set module options
---@param opts? GitBranchCommandOpts
function M.setup(opts)
	if setup == true then return end
	setup = true

	M.opts = vim.tbl_extend("force", M.opts, opts or {})
end


return M
