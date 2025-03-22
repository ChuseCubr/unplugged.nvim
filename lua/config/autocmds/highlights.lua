-- UNIVERSAL HIGHLIGHTS FOR ALL COLORSCHEMES


-- SETTINGS
local highlight_comments = true
local highlight_todo = true
local transparent_background = false

local function highlight_comment_setter()
	if vim.o.background == "dark" then
		vim.api.nvim_set_hl(0, "Comment", { fg = "NvimLightYellow" })
	else
		vim.api.nvim_set_hl(0, "Comment", { fg = "NvimDarkGray2", bg = "NvimLightYellow" })
	end
end

local highlight_todo_patterns = {
	["TODO"] = "Todo",
	["FIXME"] = "Fixme",
}

local highlight_todo_setters = {
	function() vim.api.nvim_set_hl(0, "Todo", { fg = "NvimDarkGray2", bg = "NvimLightMagenta" }) end,
	function() vim.api.nvim_set_hl(0, "Fixme", { fg = "NvimDarkGray2", bg = "NvimLightRed" }) end,
}

local group_prefix = "UnpluggedHighlight"


-- HIGHLIGHT COMMENTS
_G.HighlightComments = {}

---Prevents enabling twice (overwrites original highlight)
local highlight_comments_guard = false

---@type vim.api.keyset.hl_info
local old_comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })

local highlight_comments_group_name = group_prefix .. "Comment"
local highlight_comments_group = vim.api.nvim_create_augroup(highlight_comments_group_name, { clear = true })

local function highlight_comments_enable()
	if highlight_comments_guard then return end
	highlight_comments_guard = true

	old_comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
	highlight_comment_setter()

	highlight_comments = true
end

---Highlight comments in bright yellow
---@param enable? boolean
function _G.HighlightComments.enable(enable)
	if enable == false then
		vim.api.nvim_set_hl(0, "Comment", { fg = old_comment_hl.fg })
		vim.api.nvim_clear_autocmds({ group = highlight_comments_group })
		highlight_comments_guard = false
		highlight_comments = false
		return
	end

	vim.api.nvim_create_autocmd("Colorscheme", {
		group = highlight_comments_group,
		callback = function()
			highlight_comments_guard = false
			highlight_comments_enable()
		end,
	})

	highlight_comments_enable()
end

---Toggle highlighting comments in bright yellow
function _G.HighlightComments.toggle()
	_G.HighlightComments.enable(not highlight_comments)
end

-- HIGHLIGHT TODO
_G.HighlightTodo = {}

---Keeps track of which windows have matches
local enabled_windows = {}

local highlight_todo_group_name = group_prefix .. "Todo"
local highlight_todo_group = vim.api.nvim_create_augroup(highlight_todo_group_name, { clear = true })

local function highlight_todo_enable()
	-- matches stack, so only add if this is a new window
	local win = vim.api.nvim_get_current_win()
	if vim.list_contains(enabled_windows, win) then return end

	for _, setter in ipairs(highlight_todo_setters) do
		setter()
	end

	table.insert(enabled_windows, win)
	for pattern, highlight in pairs(highlight_todo_patterns) do
		vim.fn.matchadd(highlight, pattern)
	end

	highlight_todo = true
end

---Highlight TODO and FIXME. Pass `false` to disable.
---@param enable? boolean
function _G.HighlightTodo.enable(enable)
	if enable == false then
		vim.fn.clearmatches()
		enabled_windows = {}
		vim.api.nvim_clear_autocmds({ group = highlight_todo_group_name })
		highlight_todo = false
		return
	end

	vim.api.nvim_create_autocmd({ "WinEnter", "VimEnter" }, {
		group = highlight_todo_group,
		callback = highlight_todo_enable,
	})

	highlight_todo_enable()
end

---Toggle highlighting TODO and FIXME
function _G.HighlightTodo.toggle()
	_G.HighlightTodo.enable(not highlight_todo)
end

-- TRANSPARENT BACKGROUND
_G.TransparentBackground = {}

---Prevents enabling twice (overwrites original highlight)
local transparent_background_guard = false

---@type vim.api.keyset.hl_info
local old_normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

local transparent_background_group_name = group_prefix .. "Transparency"
local transparent_background_group = vim.api.nvim_create_augroup(transparent_background_group_name, { clear = true })

local function transparent_background_enable()
	if transparent_background_guard then return end
	transparent_background_guard = true

	old_normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
	vim.api.nvim_set_hl(0, "Normal", { bg = nil })
	transparent_background = true
end

---Enables transparent background
---@param enable? boolean
function _G.TransparentBackground.enable(enable)
	if enable == false then
		vim.api.nvim_set_hl(0, "Normal", { bg = old_normal_hl.bg })
		vim.api.nvim_clear_autocmds({ group = transparent_background_group })
		transparent_background_guard = false
		transparent_background = false
		return
	end

	vim.api.nvim_create_autocmd("Colorscheme", {
		group = transparent_background_group,
		callback = function()
			transparent_background_guard = false
			transparent_background_enable()
		end,
	})

	transparent_background_enable()
end

---Toggles transparent background
function _G.TransparentBackground.toggle()
	_G.TransparentBackground.enable(not transparent_background)
end

-- ENABLE
_G.HighlightComments.enable(highlight_comments)
-- _G.HighlightTodo.enable(highlight_todo)
_G.TransparentBackground.enable(transparent_background)
