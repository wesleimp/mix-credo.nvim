# mix-credo.nvim

Lsp diagnostics for mix credo

![mix credo issues](/assets/screenshot.png "Mix credo issues").

## Requirements

- [credo](https://github.com/rrrene/credo)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation

Install this plugin by using your favorite plugin manager

**Packer**

```lua
use({ "wesleimp/mix-credo.nvim" })
```

**Plug**

```vim
Plug 'wesleimp/mix-credo.nvim'
```

## Setup

Here's a setup example with the default values

```lua
require("mix-credo").setup({
  patterns = { "*.ex", "*.exs" }, -- for augroup
  mappings = {
    warning = vim.diagnostic.severity.ERROR,
    consistency = vim.diagnostic.severity.WARN,
    readability = vim.diagnostic.severity.HINT,
    refactor = vim.diagnostic.severity.HINT,
    desingn = vim.diagnostic.severity.HINT,
  },
})
```

The `mix-credo` setup creates an `augroup` assinging `BufEnter` and `BufWritePost`, in that way, `mix credo` runs immediately when you open or save a file.

It's also possible to run manually by using the command `:MixCredo`

## LICENSE

[MIT](./LICENSE)
