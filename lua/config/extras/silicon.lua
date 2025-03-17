vim.api.nvim_create_user_command("Silicon", function()
	vim.fn.jobstart({
		"silicon",
		"--from-clipboard",
		"--to-clipboard",
		"-l",
		vim.bo.filetype,
	}, {
		cwd = "d:/scoop/apps/silicon/current",
	})
end, {
	force = true,
	desc = "Generate code snippet screenshot",
})

vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y<cmd>Silicon<CR>', { desc = "[Y]ank as screenshot" })
