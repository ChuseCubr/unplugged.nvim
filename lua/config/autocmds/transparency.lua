-- Transparent background for all colorschemes


-- Settings
local opts = {}
opts.enable = false


-- PRIVATE FIELDS / METHODS

---Prevents enabling twice (overwrites original highlight)
local guard = false

---@type vim.api.keyset.hl_info
local old_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

local group_name = _G.UnpluggedPrefix .. "Transparency"
local group = vim.api.nvim_create_augroup(group_name, { clear = true })

local function enable()
	if guard then return end
	guard = true

	old_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
	vim.api.nvim_set_hl(0, "Normal", { bg = nil })
	opts.enable = true
end

local function disable()
	vim.api.nvim_set_hl(0, "Normal", { bg = old_hl.bg })
	vim.api.nvim_clear_autocmds({ group = group })
	guard = false
	opts.enable = false
end

-- PUBLIC MODULE

_G.TransparentBackground = {}

---Enables transparent background. Pass `false` to disable
---@param enabled? boolean
function _G.TransparentBackground.enable(enabled)
	if enabled == false then
		disable()
		return
	end

	vim.api.nvim_create_autocmd("Colorscheme", {
		group = group,
		callback = function()
			guard = false
			enable()
		end,
	})

	enable()
end

---Toggles transparent background
function _G.TransparentBackground.toggle()
	_G.TransparentBackground.enable(not opts.enable)
end


-- ENABLE

_G.TransparentBackground.enable(opts.enable)
