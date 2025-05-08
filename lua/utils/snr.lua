--- Finds the <SNR> of a given script
--- - Useful for accessing internal scripts (like Netrw)
--- - Uses memoization
--- - See `/after/ftplugin/netrw.lua` for example usage
local M = {}

local setup = false
local scripts = {}
local pattern_memo = {}

---Gets script number of script at the given path
---@param path string Path to the script
function M.getSnrByPath(path)
	return scripts[path]
end

---Gets script number of script with the given pattern
---@param pattern string See :h nvim_get_runtime_file
function M.getSnrByPattern(pattern)
	if pattern_memo[pattern] then
		return pattern_memo[pattern]
	end

	local path = vim.api.nvim_get_runtime_file(pattern, false)[1]
	local id = M.getSnrByPath(path)
	pattern_memo[pattern] = id

	return id
end

function M.setup()
	if setup then return end
	local scriptnames = vim.api.nvim_exec("scriptnames", { output = true })

	vim.iter(
		ipairs(
			vim.split(scriptnames.output, "\n")
		)
	):each(function(idx, scriptname)
		local path = string.match(scriptname, "^%s*%d+: (.+)")
		local normalized = vim.fs.normalize(path)
		scripts[normalized] = idx
	end)

	setup = true
end

return M
