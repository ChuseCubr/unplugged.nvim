local picker = { }

vim.api.nvim_exec = vim.api.nvim_exec2

function picker.bufs(opts)
	opts = opts or {}
	opts.loclist = opts.loclist or true

	local ls = vim.api.nvim_exec("ls", { output = true })

	local listed_bufs = vim.tbl_map(
		function(ls_line)
			local buf = tonumber(ls_line:match("^%s*%d+"))
			local line = tonumber(ls_line:match("%d+$"))

			return {
				bufnr = buf,
				lnum = line
			}
		end,
		vim.split(ls.output, "\n")
	)

	if opts.loclist then
		vim.fn.setloclist(0, {}, "r", { items = listed_bufs, title = "Open buffers" })
		vim.cmd("lopen")
	else
		vim.fn.setqflist({}, "r", { items = listed_bufs, title = "Open buffers" })
		vim.cmd("copen")
	end
end

_G.Picker = picker
