local M = {}

-- get SNR of Netrw
local snr = require("utils.snr")
snr.setup()
local netrwSnr

local function getSnr()
	local runtimePaths = vim.api.nvim_list_runtime_paths()
	for _, path in ipairs(runtimePaths) do
		if string.find(path, "netrw$") then
			return snr.getSnrByPath(path .. "/autoload/netrw.vim")
		end
	end

	return snr.getSnrByPattern("**/autoload/netrw.vim")
end

local setup = false
local PMap
local VMap
local OMap

-- utils
local function invertAlts()
	vim.g.netrw_alto = 1 - vim.g.netrw_alto
	vim.g.netrw_altv = 1 - vim.g.netrw_altv
end

local function invertWindowSize()
	vim.g.netrw_winsize = 100 - vim.g.netrw_winsize
end

M.PCallback = function()
	invertAlts()
	vim.api.nvim_feedkeys(PMap, "nt", false)
	vim.schedule(invertAlts)
end

M.VCallback = function()
	invertWindowSize()
	vim.api.nvim_feedkeys(VMap, "nt", false)
	vim.schedule(invertWindowSize)
end

M.OCallback = function()
	invertWindowSize()
	vim.api.nvim_feedkeys(OMap, "nt", false)
	vim.schedule(invertWindowSize)
end

M.setup = function()
	if setup then return end
	netrwSnr = getSnr()

	-- `nmap` mappings taken from Netrw buffer
	local PMapTemplate = ":<C-U>call <SNR>%d_NetrwPreview(<SNR>%d_NetrwBrowseChgDir(1,<SNR>%d_NetrwGetWord(),1,1))<CR>"
	local PMapString = PMapTemplate:gsub("%%d", netrwSnr)
	PMap = vim.api.nvim_replace_termcodes(PMapString, true, false, true)

	local VMapTemplate = ":call <SNR>%d_NetrwSplit(5)<CR>"
	local VMapString = VMapTemplate:gsub("%%d", netrwSnr)
	VMap = vim.api.nvim_replace_termcodes(VMapString, true, false, true)

	local OMapTemplate = ":call <SNR>%d_NetrwSplit(3)<CR>"
	local OMapString = OMapTemplate:gsub("%%d", netrwSnr)
	OMap = vim.api.nvim_replace_termcodes(OMapString, true, false, true)

	setup = true
	vim.notify("Custom Netrw maps loaded", vim.log.levels.INFO)
end

return M
