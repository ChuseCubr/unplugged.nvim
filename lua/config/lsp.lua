-- diagnostics
vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = { current_line = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "X",
			[vim.diagnostic.severity.WARN] = "!",
			[vim.diagnostic.severity.HINT] = "H",
			[vim.diagnostic.severity.INFO] = "i",
		},
		sign_hl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
			[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
			[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
		},
	},
})

-- attach
local group = vim.api.nvim_create_augroup(_G.UnpluggedPrefix .. "Lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then return end

		-- navigation
		vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { desc = "Go to declaration" })
		vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

		-- enable autocompletion
		vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
			autotrigger = true
		})

		vim.schedule(function()
			vim.notify(
				string.format( "`%s` attached to buffer %d", client.name, args.buf),
				vim.log.levels.INFO
			)
		end)
	end,
})


local lsps = vim.iter(vim.fs.dir(vim.fn.stdpath("config") .. "/lsp"))
		:map(function(file)
			return vim.fn.fnamemodify(file, ":t:r")
		end)
		:totable()

vim.lsp.config("*", {
	root_markers = { ".git" },
})

vim.lsp.enable(lsps)
