local M = {}

function M.find_root(markers)
	return vim.fs.dirname(vim.fs.find(markers, { upward = true })[1])
end

---@param config (vim.lsp.ClientConfig | { root_markers: string[] })
function M.init_lsp_client(config, opts)
	return function()
		opts = opts or {}

		config.name = config.cmd[1]
		config.root_dir = M.find_root(config.root_markers)
		opts.silent = true

		local client = vim.lsp.start(config, opts)
		if client == nil then
			vim.schedule(function()
				vim.api.nvim_echo({
					{
						"Failed to start LSP Server for " .. config.name,
						"DiagnosticError",
					}
				}, false, {})
			end)
			return
		end

		vim.lsp.buf_attach_client(0, client)
	end
end

return M
