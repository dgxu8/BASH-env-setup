local lsp_list = {
    "clangd",
    "basedpyright",
    "ruff",
    "lua_ls",
    "marksman",
    "rust_analyzer",
}
local plugin = {
    "mason-org/mason-lspconfig.nvim",
    event = "BufReadPost",
    dependencies = {
        "mason-org/mason.nvim",
        "neovim/nvim-lspconfig",
    },
    opts = {
        automatic_enable = lsp_list,
        ensure_installed = lsp_list,
        automatic_installation = true,
    },
}

vim.lsp.config('clangd', {
    cmd = {"clangd", "--function-arg-placeholders=0", "--offset-encoding=utf-16"},
})

-- vim.lsp.config('basedpyright', { })

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {
                    'vim',
                    'require'
                },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})
return plugin
