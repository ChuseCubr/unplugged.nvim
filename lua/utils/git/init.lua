-- Git utils
local M = {}
M.branch = require("utils.git.commands.branch")
M.status = require("utils.git.commands.status")
M.buf_status = require("utils.git.commands.buf_status")
M.buf_diff = require("utils.git.commands.buf_diff")

M.chunk_types = M.buf_diff.chunk_types

local common = require("utils.common")


-- OPTIONS =====================================================================

local opts = {}

---Events to trigger calling `git branch` commands
---@type string[]
opts.branch_events = { "BufEnter", "ShellCmdPost", "FocusGained" }

---Events to trigger calling `git status` and `git diff` commands
---@type string[]
opts.file_events = { "BufEnter", "ShellCmdPost", "FocusGained", "BufWritePost" }

---Prefix for events to be emitted after updating Git info
---@type string
opts.prefix = _G.UnpluggedPrefix .. "Git"


-- TYPES =======================================================================

M.events = {
	BRANCH = opts.prefix .. "Branch",
	STATUS = opts.prefix .. "Status",
	BUF_STATUS = opts.prefix .. "BufStatus",
	BUF_DIFF = opts.prefix .. "BufDiff",
}


-- PRIVATE FIELDS / METHODS ====================================================

---Setup guard
local setup = false

-- PUBLIC METHODS ==============================================================

---Create autocmds to update Git info automatically
---Upon setup, autocmds will emit the events in `opts.events`:
function M.setup()
	if setup == true then return end
	setup = true

	M.branch.setup({ event = M.events.BRANCH })
	M.status.setup({ event = M.events.STATUS })
	M.buf_status.setup({ event = M.events.BUFF_STATUS })
	M.buf_diff.setup({event = M.events.BUFF_STATUS})

	local git_group = vim.api.nvim_create_augroup(opts.prefix, { clear = true })

	vim.api.nvim_create_autocmd(opts.branch_events, {
		group = git_group,
		callback = function() M.branch.update() end
	})

	vim.api.nvim_create_autocmd(opts.file_events, {
		group = git_group,
		callback = function(args)
			M.status.update()

			if not common.check_valid_buf(args.buf) then return end
			M.buf_status.update(args.buf)
			M.buf_diff.update(args.buf)
		end
	})
end

M.setup()

return M
