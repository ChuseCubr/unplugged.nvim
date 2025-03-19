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

-- TODO: TO BE DEPRECATED, will become defaults in 0.11
-- unimpaired mappings
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

vim.keymap.set("n", "[q", "<cmd>cprev<cr>zz", { desc = "Prev quickfix entry" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix entry" })
vim.keymap.set("n", "[Q", "<cmd>cr<cr>zz", { desc = "First quickfix entry" })
vim.keymap.set("n", "]Q", "<cmd>cla<cr>zz", { desc = "Last quickfix entry" })
vim.keymap.set("n", "[<c-q>", "<cmd>cpf<cr>zz", { desc = "Prev quickfix file" })
vim.keymap.set("n", "]<c-q>", "<cmd>cnf<cr>zz", { desc = "Next quickfix file" })

vim.keymap.set("n", "[l", "<cmd>lprev<cr>zz", { desc = "Prev location entry" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>zz", { desc = "Next location entry" })
vim.keymap.set("n", "[L", "<cmd>lr<cr>zz", { desc = "First location entry" })
vim.keymap.set("n", "]L", "<cmd>lla<cr>zz", { desc = "Last location entry" })
vim.keymap.set("n", "[<c-l>", "<cmd>lpf<cr>zz", { desc = "Prev location file" })
vim.keymap.set("n", "]<c-l>", "<cmd>lnf<cr>zz", { desc = "Next location file" })

vim.keymap.set("n", "[a", "<cmd>N<cr>zz", { desc = "Prev file in args list" })
vim.keymap.set("n", "]a", "<cmd>n<cr>zz", { desc = "Next file in args list" })
vim.keymap.set("n", "[A", "<cmd>rew<cr>zz", { desc = "First file in args list" })
vim.keymap.set("n", "]A", "<cmd>la<cr>zz", { desc = "Last file in args list" })

vim.keymap.set("n", "[b", "<cmd>bp<cr>zz", { desc = "Next open buffer" })
vim.keymap.set("n", "]b", "<cmd>bn<cr>zz", { desc = "Prev open buffer" })
vim.keymap.set("n", "[B", "<cmd>bf<cr>zz", { desc = "First open buffer" })
vim.keymap.set("n", "]B", "<cmd>bl<cr>zz", { desc = "Last open buffer" })

vim.keymap.set("n", "[<space>", "mzO<esc>`z", { desc = "Insert empty line before" })
vim.keymap.set("n", "]<space>", "mzo<esc>`z", { desc = "Insert empty line after" })
