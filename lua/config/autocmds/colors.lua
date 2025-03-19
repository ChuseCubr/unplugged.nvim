-- universal highlights for all colorschemes

-- highlight comments
local highlight_comments = true
local old_comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })

function _G.HighlightCommentsEnable()
	highlight_comments = true
	vim.api.nvim_set_hl(0, "Comment", { ctermfg = 11, fg = "NvimLightYellow" })
end

function _G.HighlightCommentsDisable()
	vim.api.nvim_set_hl(0, "Comment", { fg = old_comment_hl.fg })
	highlight_comments = false
end

function _G.HighlightCommentsToggle()
	highlight_comments = not highlight_comments
	if highlight_comments then
		_G.HighlightCommentsEnable()
	else
		_G.HighlightCommentsDisable()
	end
end

local highlight_comments_group = vim.api.nvim_create_augroup("UnpluggedComments", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = highlight_comments_group,
	callback = function()
		if highlight_comments ~= true then
			return
		end
		if vim.o.background == "dark" then
			vim.api.nvim_set_hl(0, "Comment", { ctermfg = 11, fg = "NvimLightYellow" })
		else
			vim.api.nvim_set_hl(0, "Comment", { ctermfg = 0, ctermbg = 11, fg = "NvimDarkGray2", bg = "NvimLightYellow" })
		end
	end,
})

-- transparent background
local transparent_background = false
local old_normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

function _G.TransparentBackgroundEnable()
	transparent_background = true
	old_normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
	vim.api.nvim_set_hl(0, "Normal", { bg = nil })
end

function _G.TransparentBackgroundDisable()
	transparent_background = false
	vim.api.nvim_set_hl(0, "Normal", { bg = old_normal_hl.bg })
end

function _G.TransparentBackgroundToggle()
	transparent_background = not transparent_background
	if transparent_background then
		_G.TransparentBackgroundEnable()
	else
		_G.TransparentBackgroundDisable()
	end
end

local transparent_background_group = vim.api.nvim_create_augroup("UnpluggedTransparency", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = transparent_background_group,
	callback = function()
		if vim.g.neovide or transparent_background ~= true then
			return
		end
		vim.api.nvim_set_hl(0, "Normal", { bg = nil })
	end,
})

vim.api.nvim_create_user_command("HighlightCommentsEnable", _G.HighlightCommentsEnable, {})
vim.api.nvim_create_user_command("HighlightCommentsDisable", _G.HighlightCommentsDisable, {})
vim.api.nvim_create_user_command("HighlightCommentsToggle", _G.HighlightCommentsToggle, {})

vim.api.nvim_create_user_command("TransparentBackgroundEnable", _G.TransparentBackgroundEnable, {})
vim.api.nvim_create_user_command("TransparentBackgroundDisable", _G.TransparentBackgroundDisable, {})
vim.api.nvim_create_user_command("TransparentBackgroundToggle", _G.TransparentBackgroundToggle, {})

vim.api.nvim_exec_autocmds("ColorScheme", {})
