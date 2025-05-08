# Unplugged (WIP)

My no-plugin Neovim config

## Features

* LSP setup
* Git integration
  * Statusline components
  * Gutter signs
  * Chunk navigation (`]g` and `[g`)
  * Picker integration
* Custom Commands
  * Quickfix/location list pickers (WIP)
    * Listed buffers (`<leader><leader>` or `:lua Unplugged.Picker.bufs()`)\*
    * Unstaged files (`<leader>gf` or `:lua Unplugged.Picker.unstaged_files()`)\*
    * Unstaged chunks (`<leader>gc` or `:lua Unplugged.Picker.unstaged_chunks()`)\*
  * Universal highlights (persistent across colorschemes) for
    * Comments (`:lua Unplugged.HighlightComments.toggle()`)
    * TODO, etc. comments (`:lua Unplugged.HighlightTodo.toggle()`)
    * Transparent background (`:lua Unplugged.TransparentBackground.toggle()`)
* Custom quickfix/location list mappings
  * Close on select (`<CR>`, default mapping is now `o`)
  * Preview (`p`)
* More consistent Netrw mappings
  * `p` respects `g:netrw_altv` and `g:netrw_alto`
  * `v` and `o` respect `g:netrw_winsize`

\* `<leader>` is set to `<space>`
