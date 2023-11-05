local plugin = {"ray-x/lsp_signature.nvim"}

plugin.event = "VeryLazy"
function plugin.config()
    require("lsp_signature").setup({
        doc_lines = 0,
        max_width = 100,
        transparency = 10,
    })
end

return plugin
