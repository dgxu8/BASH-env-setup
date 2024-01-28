local plugin = {"ray-x/lsp_signature.nvim"}

plugin.event = "VeryLazy"
function plugin.config()
    require("lsp_signature").setup({
        doc_lines = 0,
        max_width = 100,
        transparency = 10,
    })
end

plugin.keys = {
    {"<c-k>", function()
        require("lsp_signature").toggle_float_win()
    end, mode = "i"},
}

return plugin
