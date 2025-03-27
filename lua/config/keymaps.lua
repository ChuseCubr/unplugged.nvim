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
vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "[E]rrors" })
vim.keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "To [L]ocation list" })
vim.keymap.set("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "To [Q]uickfix list" })


-- custom commands
vim.keymap.set("n", "<leader><leader>", _G.Picker.bufs, { desc = "Open buffers (picker)" })
