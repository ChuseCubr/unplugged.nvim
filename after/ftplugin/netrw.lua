-- Netrw is inconsistent with how it handles it options.
--
-- According to the documentation:
-- - g:netrw_winsize controls the size of the Netrw split
-- - g:netrw_altv controls left/right splitting
-- - g:netrw_alto controls up/down splitting
--
-- However:
-- - `p` inverts g:netrw_altv and g:netrw_alto
-- - `v` and `o` invert the window size
--
-- These mappings aim to bring consistency

local mappings = require("utils.netrw")
mappings.setup()

vim.keymap.set("n", "p", mappings.PCallback, { noremap = true, buffer = true, desc = "Preview" })
vim.keymap.set("n", "v", mappings.VCallback, { noremap = true, buffer = true, desc = "Open in a vertical split" })
vim.keymap.set("n", "o", mappings.OCallback, { noremap = true, buffer = true, desc = "Open in a horizontal split" })
