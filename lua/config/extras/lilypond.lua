local group = vim.api.nvim_create_augroup("lilypond", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = "*.ly",
	callback = function (event)
		vim.system(
			{ "lilypond", event.file },
			{
				text = true,
				cwd = vim.fn.fnamemodify(event.file, ":p:h")
			},
			function(obj)
				vim.schedule(function()
					if (obj.code == 0) then
						vim.notify(
							"Compiled " .. event.file,
							vim.log.levels.INFO
						)
					else
						vim.notify(
							"Error while compiling " .. event.file .. "\nRun :make to see why",
							vim.log.levels.ERROR
						)
					end
				end)
			end)
	end,
});
