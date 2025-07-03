local plugin = {"neovim/nvim-lspconfig"}
local user = {}

plugin.dependencies = {
    {"hrsh7th/cmp-nvim-lsp"},
    {"mason-org/mason-lspconfig.nvim"},
    {"p00f/clangd_extensions.nvim"},
}

plugin.cmd = {"LspInfo", "LspInstall", "LspUnInstall"}
plugin.event = {"BufReadPre", "BufNewFile"}

function plugin.config()
    local lspconfig = require("lspconfig")
    local lsp_defaults = lspconfig.util.default_config

    lsp_defaults.capabilities = vim.tbl_deep_extend(
        "force",
        lsp_defaults.capabilities,
        require("cmp_nvim_lsp").default_capabilities()
    )

    local group = vim.api.nvim_create_augroup("lsp_cmds", {clear = true})

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        desc = "LSP actions",
        callback = user.on_attach
    })
end

function user.on_attach()
    local bufmap = function(mode, lhs, rhs)
        local opts = {buffer = true}
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
    bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
    bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
    bufmap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
    bufmap("n", "<space><space>", "<cmd>lua vim.lsp.buf.hover()<cr>")

    vim.keymap.set("n", "<leader>lh", function()
        require("clangd_extensions.inlay_hints").toggle_inlay_hints()
    end, {buffer = true, desc = "[l]sp [h]ints toggle"})
end

-- New with nvim 0.11 we need to st this to show the message to the side
vim.diagnostic.config({
    virtual_text = true,
})
vim.keymap.set("n", "<leader>tt", vim.diagnostic.open_float, { desc = "Open diagnostic in floating window" })

local inactive_hl = false
local function toggle_inactive_hl ()
  if inactive_hl then
    -- Turn on highlighting in inactive regions (unreachable #if blocks)
    vim.api.nvim_set_hl(0, '@lsp.type.comment.c', { fg="#a5a6a7", italic=true, })
  else
    -- Turn off highlighting in inactive regions (unreachable #if blocks)
    vim.api.nvim_set_hl(0, '@lsp.type.comment.c', {})
  end
  inactive_hl = not inactive_hl
end
vim.keymap.set("n", "<leader>ti", toggle_inactive_hl, { desc = "Toggle syntax highlighting" })

return plugin
