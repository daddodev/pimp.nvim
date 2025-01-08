# pimp.nvim

Neovim plugin for (Neovim pimp module)[https://github.com/pimpmyrice-modules/neovim]

```lua
use({
    "daddodev/pimp.nvim",
    config = function()
        require("pimp").setup {
            run_on_start = true,
            watch = true,
        }
    end,
})
```
