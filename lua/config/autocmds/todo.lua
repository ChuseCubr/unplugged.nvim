-- Enable TODO etc. pattern highlighting
M = {}


-- Settings
local opts = {}

-- Enable/disable
opts.enable = true

---Highlight and pattern in a `table<hl_group, pattern>`
---@type table<string, string>
opts.patterns = {
	["Todo"] = "TODO",
	["Fixme"] = "FIXME",
}

---Highlight definitions as a callback
---@type table<string, fun()>
opts.highlight_setters = {
	["Todo"] = function()
		vim.api.nvim_set_hl(0, "Todo", { fg = "NvimDarkGray2", bg = "NvimLightMagenta" })
	end,
	["Fixme"] = function()
		vim.api.nvim_set_hl(0, "Fixme",  { fg = "NvimDarkGray2", bg = "NvimLightRed" })
	end,
}


-- PRIVATE FIELDS / METHODS

---Keeps track of which windows have matches
---@type integer[]
local windows = {}

---@type table<string, vim.api.keyset.highlight>
local old_highlights = {}

local group_name = _G.UnpluggedPrefix .. "Todo"
local group = vim.api.nvim_create_augroup(group_name, { clear = true })

local function enable()
	-- matches stack, so only add if this is a new window
	local win = vim.api.nvim_get_current_win()
	if vim.list_contains(windows, win) then return end

	for highlight, setter in pairs(opts.highlight_setters) do
		old_highlights[highlight] = vim.api.nvim_get_hl(0, { name = highlight }) --[[@as vim.api.keyset.highlight]]
		setter()
	end

	table.insert(windows, win)
	for highlight, pattern in pairs(opts.patterns) do
		vim.fn.matchadd(highlight, pattern)
	end

	opts.enable = true
end

local function disable()
	windows = {}
	for highlight, hl_opts in pairs(old_highlights) do
		vim.api.nvim_set_hl(0, highlight, hl_opts)
	end
	old_highlights = {}

	vim.fn.clearmatches()
	vim.api.nvim_clear_autocmds({ group = group_name })
	opts.enable = false
end


-- PUBLIC METHODS

---Highlight TODO etc. patterns. Pass `false` to disable.
---@param enabled? boolean
function M.enable(enabled)
	if enabled == false then
		disable()
		return
	end

	vim.api.nvim_create_autocmd({ "Colorscheme", "WinEnter", "VimEnter" }, {
		group = group,
		callback = function()
			windows = {}
			enable()
		end
	})

	enable()
end

---Toggle highlighting TODO etc. patterns
function M.toggle()
	M.enable(not opts.enable)
end


-- Enable
M.enable(opts.enable)

-- Expose
_G.Unplugged.HighlightTodo = M
