require("config.options.editor")
require("config.options.ui")
require("config.options.neovide")

local is_wsl = vim.fn.has("unix") == 1 and vim.fn.filereadable("/proc/sys/fs/binfmt_misc/WSLInterop")
if is_wsl then
	require("config.options.wsl")
else
	require("config.options.windows")
end
