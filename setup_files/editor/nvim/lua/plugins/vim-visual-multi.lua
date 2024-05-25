local plugin = {"mg979/vim-visual-multi"}

plugin.name = "vim-visual-multi"

plugin.keys = {
    { "<c-n>", mode = { "n", "x", "v" }, desc = "Select words" },
    { "<c-up>", mode = { "n", "x", "v" }, desc = "Create cursor up" },
    { "<c-down>", mode = { "n", "x", "v" }, desc = "Create cursor down" },
    { "<c-left>", mode = { "n", "x", "v" }, desc = "Select left" },
    { "<c-right>", mode = { "n", "x", "v" }, desc = "Select right" },
}

-- vim visual multi color mode
vim.api.nvim_command("let g:VM_theme = 'iceblue'")

return plugin
