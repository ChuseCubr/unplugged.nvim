local git = require("utils.git")

local namespace = vim.api.nvim_create_namespace(_G.UnpluggedPrefix .. "GitSigns")
local group = vim.api.nvim_create_augroup(_G.UnpluggedPrefix .. "GitSigns", { clear = true })

local guard = false

local highlights = {
	[git.chunk_types.ADDED] = "Added",
	[git.chunk_types.REMOVED] = "Removed",
	[git.chunk_types.CHANGED] = "Changed",
}

local signs = {
	[git.chunk_types.ADDED] = "+",
	[git.chunk_types.REMOVED] = "-",
	[git.chunk_types.CHANGED] = "|",
}

local function set_extmarks(buf)
	vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
	local chunks = git.buf_diff.get(buf)
	if not chunks then return end
	for _, chunk in ipairs(chunks) do
		-- quirks around zero-based indexing
		-- added and changed chunks are 1 ahead of the actual position
		-- removed chunks need no offset
		local offset = chunk.type == git.chunk_types.REMOVED and 0 or 1
		vim.api.nvim_buf_set_extmark(buf, namespace, chunk.line - offset, 0, {
			end_row = chunk.line + chunk.count - (offset + 1), -- extra offset for end-inclusive indexing
			sign_text = signs[chunk.type],
			sign_hl_group = highlights[chunk.type],
			priority = 9, -- diagnostics (10) should have prio over this
		})
	end
end

local function setup()
	if guard then return end
	guard = true

	vim.api.nvim_create_autocmd("User", {
		pattern = git.events.BUF_DIFF,
		group = group,
		callback = function(args)
			set_extmarks(args.data.buf)
		end
	})
end

setup()
