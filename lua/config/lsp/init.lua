local lsp_configs_path = vim.fn.stdpath("config") .. "/lua/config/lsp"

for name, type in vim.fs.dir(lsp_configs_path) do
	name = vim.fn.fnamemodify(name, ":r")
	if type == "file" and name ~= "init" and name ~= "utils" then
		require("config.lsp." .. name)
	end
end

local group = vim.api.nvim_create_augroup("GenericLspAttach", { clear = true })

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
		vim.keymap.set({"s", "i"}, "<c-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })

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

		vim.api.nvim_echo({
			{
				"LSP Client for `" .. client.name .. "` successfully attached",
				"DiagnosticOk",
			}
		}, false, {})
	end,
})
