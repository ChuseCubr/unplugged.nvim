local lsp = require("utils.lsp")
lsp.setup()

local lsp_configs_path = vim.fn.stdpath("config") .. "/lua/config/lsp"

for name, type in vim.fs.dir(lsp_configs_path) do
	name = vim.fn.fnamemodify(name, ":r")
	if type == "file" and name ~= "init" and name ~= "utils" then
		require("config.lsp." .. name)
	end
end
