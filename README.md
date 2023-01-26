# tktodo.nvim

A telescope extension to toggle todo items in notes from the telekasten.nvim home directory.


## Installation

Install [telekasten.nvim](https://github.com/renerocksai/telekasten.nvim) and its dependencies.
Add the repository line to your package manager e.g. packer and sync
```lua
    use({"tarting/tktodo.nvim"})
```

Add the following to your telekasten or telescope config.
```lua
require('telescope').load_extension('tktodo')
vim.keymap.set('n', '<leader>zT', require('telescope').extensions.tktodo.todo(), {})
```

