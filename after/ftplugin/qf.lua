-- close qf/loclist upon selecting entry
-- added complexity to distinguish between separate lists
vim.keymap.set("n", "<cr>", function()
	local win = vim.api.nvim_get_current_win()

	-- select entry
	local keys = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
	vim.api.nvim_feedkeys(keys, "nt", false)

	-- schedule to ensure it runs after nvim_feedkeys
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, false)
		end
	end)
end, { noremap = true, buffer = true, desc = "Select entry and close list" })

-- select without closing
vim.keymap.set("n", "p", "<cr>", { buffer = true, noremap = true, desc = "Preview (select without closing)" })
