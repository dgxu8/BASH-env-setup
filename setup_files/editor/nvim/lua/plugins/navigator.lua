local plugin = {'numToStr/Navigator.nvim'}

plugin.config = true

plugin.keys = {
    {"<c-h>", "<cmd>NavigatorLeft<cr>"},
    {"<c-j>", "<cmd>NavigatorDown<cr>"},
    {"<c-k>", "<cmd>NavigatorUp<cr>"},
    {"<c-l>", "<cmd>NavigatorRight<cr>"},
}

return plugin
