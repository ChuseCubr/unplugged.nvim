-- Netrw is inconsistent with how it handles it options.
--
-- According to the documentation:
-- - g:netrw_winsize controls the size of the Netrw split
-- - g:netrw_altv controls left/right splitting
-- - g:netrw_alto controls up/down splitting
--
-- However:
-- - `p` inverts g:netrw_altv and g:netrw_alto
-- - `v` and `o` invert the window size
--
-- These mappings aim to bring consistency

-- get SNR of Netrw
local snr = require("utils.snr")
snr.setup()
local netrwSnr = snr.getSnrByPattern("**/autoload/netrw.vim")

-- `nmap` mappings taken from Netrw buffer
local PMapTemplate = ":<C-U>call <SNR>%d_NetrwPreview(<SNR>%d_NetrwBrowseChgDir(1,<SNR>%d_NetrwGetWord(),1,1))<CR>"
local PMapString = PMapTemplate:gsub("%%d", netrwSnr)
local PMap = vim.api.nvim_replace_termcodes(PMapString, true, false, true)

local VMapTemplate = ":call <SNR>%d_NetrwSplit(5)<CR>"
local VMapString = VMapTemplate:gsub("%%d", netrwSnr)
local VMap = vim.api.nvim_replace_termcodes(VMapString, true, false, true)

local OMapTemplate = ":call <SNR>%d_NetrwSplit(3)<CR>"
local OMapString = OMapTemplate:gsub("%%d", netrwSnr)
local OMap = vim.api.nvim_replace_termcodes(OMapString, true, false, true)

-- utils
local function invertAlts()
	vim.g.netrw_alto = 1 - vim.g.netrw_alto
	vim.g.netrw_altv = 1 - vim.g.netrw_altv
end

local function invertWindowSize()
	vim.g.netrw_winsize = 100 - vim.g.netrw_winsize
end

-- mappings
vim.keymap.set("n", "p", function()
	invertAlts()
	vim.api.nvim_feedkeys(PMap, "nt", false)
	vim.schedule(invertAlts)
end, { noremap = true, buffer = true, desc = "Preview" })

vim.keymap.set("n", "v", function()
	invertWindowSize()
	vim.api.nvim_feedkeys(VMap, "nt", false)
	vim.schedule(invertWindowSize)
end, { noremap = true, buffer = true, desc = "Open in a vertical split" })

vim.keymap.set("n", "o", function()
	invertWindowSize()
	vim.api.nvim_feedkeys(OMap, "nt", false)
	vim.schedule(invertWindowSize)
end, { noremap = true, buffer = true, desc = "Open in a horizontal split" })
