local plugin = {"lewis6991/gitsigns.nvim"}

plugin.event = {'BufReadPre', 'BufNewFile'}

plugin.opts = {
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  }
}

return plugin
