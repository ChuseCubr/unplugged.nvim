---Gets git branch name
local M = {}
local common = require("utils.common")


-- OPTIONS =====================================================================

---@class GitBranchCommandOpts
---@field event string Event to emit upon update completion

---Default opts. Ignored once `setup()` is called
---@type GitBranchCommandOpts
M.opts = {
	event = "UnpluggedGitBranch",
}


-- PRIVATE FIELDS ==============================================================

---Setup guard
local setup = false

---The name of the branch the current buffer is in
---@type string
local branch = ""

local function update(obj)
	if obj.stdout == nil or obj.stdout:len() == 0 then
		branch = ""
		return
	end

	branch = obj.stdout:sub(1, -2)
end


-- PUBLIC METHODS ==============================================================

---Asynchronousely updates tracked branch name
---Emits the event set in `opts.event` upon completion
---Get the current value using `get()`
function M.update()
	vim.system(
		{ "git", "branch", "--show-current" },
		common.get_cwd_cmd_opts(),
		function(obj)
			update(obj)
			common.exec_autocmds(M.opts.event)
		end
	)
end

---Gets the last tracked branch name
---Update the value using `update()`
function M.get()
	return branch
end

---Set module options
---@param opts? GitBranchCommandOpts
function M.setup(opts)
	if setup == true then return end
	setup = true

	M.opts = vim.tbl_extend("force", M.opts, opts or {})
end


return M
