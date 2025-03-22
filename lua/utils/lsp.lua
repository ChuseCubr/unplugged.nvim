local M = {}


-- SETTINGS

---LSP autocmd group
local group = vim.api.nvim_create_augroup("UnpluggedLsp", { clear = true })

---Buffer types to not init LSP on
---@type string[]
local do_not_attach_types = {
	"help",
	"nofile",
	"quickfix",
	"terminal",
	"prompt",
}


-- PRIVATE FIELDS

---Setup guard
local setup = false


-- PRIVATE METHODS / UTILS

---@param markers string[] List of root marker files
local function find_root(markers)
	return vim.fs.dirname(vim.fs.find(markers, { upward = true })[1])
end


-- PUBLIC METHODS

---@param config (vim.lsp.ClientConfig | { root_markers: string[] })
function M.init_lsp_client(config, opts)
	return function()
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
		local do_not_attach = vim.list_contains(do_not_attach_types, buftype)
		if do_not_attach then return end

		opts = opts or {}

		config.name = config.cmd[1]
		config.root_dir = find_root(config.root_markers)
		opts.silent = true

		local client = vim.lsp.start(config, opts)
		if client == nil then
			vim.schedule(function()
				vim.notify(
					"Failed to start LSP Server for `" .. config.name .. "`",
					vim.log.levels.ERROR
				)
			end)
			return
		end

		vim.lsp.buf_attach_client(0, client)
	end
end

---Sets up LspAttach autocmd
function M.setup()
	if setup then return end
	setup = true

	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client == nil then return end

			-- navigation
			vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { desc = "Go to declaration" })
			vim.keymap.set("i", "gD", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

			-- TODO: TO BE DEPRECATED, will become defaults in 0.11
			-- hover
			vim.keymap.set({ "s", "i" }, "<c-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })

			-- navigation
			vim.keymap.set("n", "grr", vim.lsp.buf.references, { desc = "Go to references" })
			vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { desc = "Go to implementation" })

			-- list
			vim.keymap.set("n", "gO",
				function() vim.lsp.buf.document_symbol({ loclist = true }) end,
				{ desc = "Document symbols" }
			)

			-- actions
			vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "Rename symbol" })
			vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { desc = "Code action" })

			vim.schedule(function()
				vim.notify(
					string.format(
						"LSP client for `%s` successfully attached to buffer %d (%s)",
						client.name,
						args.buf,
						vim.fn.fnamemodify(args.file, ":.")
					),
					vim.log.levels.INFO
				)
			end)
		end,
	})
end

return M
