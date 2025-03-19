local utils = require("utils.lsp")

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	callback = utils.init_lsp_client({
		init_options = { hostInfo = "neovim" },
		cmd = { "typescript-language-server.cmd", "--stdio" },
		root_markers = {
			"tsconfig.json",
			"jsconfig.json",
			"package.json",
			".git",
		},
	}),
})
