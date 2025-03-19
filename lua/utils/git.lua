local M = {}

---The name of the branch the current buffer is in
---@type string
M.branch_name = ""

---
---@type string
M.branch_status = ""
M.buf_statuses = {}

local setup = false
local git_group = vim.api.nvim_create_augroup("UnpluggedGit", { clear = true })
local git_branch_events = { "BufEnter", "ShellCmdPost", "FocusGained" }
local git_file_events = vim.list_extend(git_branch_events, { "BufWritePost" })

local function get_git_cmd_opts()
	return { text = true, cwd = vim.fn.expand("%:p:h") }
end

function M.setup(opts)
	if setup == true then return end
	setup = true

	vim.api.nvim_create_autocmd(git_branch_events, {
		group = git_group,
		callback = function()
			vim.system(
				{ "git", "branch", "--show-current" },
				get_git_cmd_opts(),
				function(obj)
					if obj.stdout == nil then
						M.branch_name = ""
						return
					end

					M.branch_name = obj.stdout:sub(1, -2)

					if opts ~= nil and opts.on_exit ~= nil then
						opts.on_exit()
					end
				end
			)
		end
	})

	vim.api.nvim_create_autocmd(git_file_events, {
		group = git_group,
		callback = function(args)
			vim.system(
				{ "git", "status", "-s" },
				get_git_cmd_opts(),
				function(obj)
					if obj.stdout == nil or obj.stdout:len() == 0 then
						M.branch_status = ""
						return
					end

					local lines = vim.split(obj.stdout, "\n", { trimempty = true })

					M.branch_status = "*"

					if opts ~= nil and opts.on_exit ~= nil then
						opts.on_exit()
					end
				end
			)

			vim.system(
				{ "git", "status", "-s", vim.fn.expand("%:p") },
				get_git_cmd_opts(),
				function(obj)
					if obj.stdout == nil then
						M.branch = ""
						return
					end

					local status = obj.stdout:sub(1, 2):gsub(" ", "-")
					M.buf_statuses[args.buf] = status

					if opts ~= nil and opts.on_exit ~= nil then
						opts.on_exit()
					end
				end
			)
		end
	})
end

return M
