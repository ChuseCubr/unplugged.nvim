local picker = require("utils.picker")
picker.setup()

local git = require("utils.git")
git.setup()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move selected block
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- still cursor on J
vim.keymap.set("n", "J", "mzJ`z")

-- diagnostics
vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Display diagnostics on current line" })
vim.keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Loclist: Errors" })
vim.keymap.set("n", "<leader>cL", vim.diagnostic.setqflist, { desc = "Qflist: Errors" })


-- custom commands
vim.keymap.set("n", "<leader><leader>", picker.bufs, { desc = "Loclist: Open buffers" })
vim.keymap.set("n", "<leader>gf", picker.unstaged_files, { desc = "Loclist: Unstaged git files" })
vim.keymap.set("n", "<leader>gc", picker.unstaged_chunks, { desc = "Loclist: Unstaged git chunks" })

vim.keymap.set("n", "]g", git.buf_diff.goto_next, { desc = "Jump to the next git chunk in the current buffer" })
vim.keymap.set("n", "[g", git.buf_diff.goto_prev, { desc = "Jump to the previous git chunk in the current buffer" })
