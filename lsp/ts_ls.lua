return {
	name = "ts_ls",
	init_options = { hostInfo = "neovim" },
	cmd = { "typescript-language-server.cmd", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = {
		"tsconfig.json",
		"jsconfig.json",
		"package.json",
		".git",
	},
}
