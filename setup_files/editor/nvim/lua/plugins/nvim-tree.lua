local plugin = {"kyazdani42/nvim-tree.lua"}

plugin.name = "nvim-tree"
plugin.cmd = {"NvimTreeToggle"}

plugin.opts = {
    sort_by = "case_sensitive",
    view = {
        width = 30,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
}

plugin.keys = {
  {"<F10>", "<cmd>NvimTreeToggle<cr>"},
  {"<F11>", "<cmd>NvimTreeFindFileToggle<cr>"},
}

return plugin
