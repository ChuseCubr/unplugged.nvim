local M = {}

---Find root folder using patterns
---@param buf integer Buffer number
---@param patterns string[] List of lua patterns
function M.find_root(buf, patterns)
	return vim.fs.root(buf or 0, function(name)
		for _, pattern in ipairs(patterns) do
			if name:match(pattern) then return true end
		end
		return false
	end)
end

---vim.system() opts for current dir
function M.get_cwd_cmd_opts()
	return { text = true, cwd = vim.fn.getcwd() }
end

---Autocmd invoker wrapper
---@param pattern string
---@param autocmd_opts? vim.api.keyset.exec_autocmds
function M.exec_autocmds(pattern, autocmd_opts)
	local default_opts = {
		pattern = pattern
	}

	autocmd_opts = vim.tbl_extend("force", default_opts, autocmd_opts or {})

	vim.schedule(function()
		vim.api.nvim_exec_autocmds("User", autocmd_opts)
	end)
end

local do_not_attach_types = {
	"help",
	"nofile",
	"quickfix",
	"terminal",
	"prompt",
}

---Checks if the current buffer is of a valid file for autocmds
---@param buf integer Buffer number
function M.check_valid_buf(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	local isfile = vim.fn.filereadable(file) == 1
	if not isfile then return false end

	local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
	if vim.list_contains(do_not_attach_types, buftype) then return false end

	return true
end

return M
