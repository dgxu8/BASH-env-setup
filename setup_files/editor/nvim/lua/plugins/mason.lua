local plugin = {"williamboman/mason.nvim"}

plugin.lazy = false
plugin.config = true

plugin.opts = {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
}

return plugin
