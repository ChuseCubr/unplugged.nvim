local M = {}

---vim.system() opts for current file dir
function M.get_cwd_cmd_opts()
	return { text = true, cwd = vim.fn.expand("%:p:h") }
end

---Expand and escape file name
---@param buf integer Buffer number
function M.get_buf_path(buf)
	return vim.fn.fnameescape(vim.api.nvim_buf_get_name(buf))
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

function M.check_valid_buf(buf)
	local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
	if ft == "netrw" then return false end

	local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
	if vim.list_contains(do_not_attach_types, buftype) then return false end

	return true
end

return M
