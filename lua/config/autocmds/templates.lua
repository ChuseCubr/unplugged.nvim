local template_path = vim.fn.stdpath("config") .. "/templates"

local group = vim.api.nvim_create_augroup("Templates", { clear = true })
local function create_template_autocmd(template, pattern)
	vim.api.nvim_create_autocmd("BufNewFile", {
		group = group,
		pattern = pattern or ("*." .. vim.fn.fnamemodify(template, ":e")),
		callback = function(ev)
			vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, vim.fn.readfile(template_path .. "/" .. template))
		end,
	})
end

local templates = vim.split(vim.fn.glob(template_path .. "/*"), "\n", { trimempty = true })
for _, v in ipairs(templates) do
	v = vim.fn.fnamemodify(v, ":t")
	create_template_autocmd(v)
end

create_template_autocmd("Makefile", "Makefile")
