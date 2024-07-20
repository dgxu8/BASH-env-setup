local plugin = {"neovim/nvim-lspconfig"}
local user = {}

plugin.dependencies = {
    {"hrsh7th/cmp-nvim-lsp"},
    {"williamboman/mason-lspconfig.nvim"},
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

    require("mason-lspconfig").setup({
        ensure_installed = {
            "clangd",
            "pylsp",
            "ruff_lsp",
            "lua_ls",
            "marksman",
        },
        handlers = {
            function(server)
                lspconfig[server].setup({})
            end,
            ["clangd"] = function()
                lspconfig.clangd.setup({
                    cmd = {"clangd", "--function-arg-placeholders=0", "--offset-encoding=utf-16"},
                })
            end,
            ["pylsp"] = function()
                lspconfig.pylsp.setup({
                    flags = {
                        allow_incremenetal_sync = false
                    },
                    settings = {
                        pylsp = {
                            plugins = {
                                pylint = {enabled = true},
                                jedi = {
                                    environment = "/usr/bin/python3",
                                    auto_import_modules = {},
                                },
                                mccabe = {enabled = false},
                                yapf = {enabled = false},
                            },
                        },
                    },
                })
            end,
            ["lua_ls"] = function()
                lspconfig.lua_ls.setup({
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
            end
        },
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

    require("clangd_extensions.inlay_hints").setup_autocmd()
    require("clangd_extensions.inlay_hints").set_inlay_hints()
end

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
