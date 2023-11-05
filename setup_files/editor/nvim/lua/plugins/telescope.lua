local plugin = {"nvim-telescope/telescope.nvim"}

plugin.branch = "0.1.x"

plugin.dependencies = {
    {"nvim-lua/plenary.nvim"},
    {"nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"},
}

plugin.cmd = {'Telescope'}

plugin.opts = {
    defaults = {
        layout_config = {
            horizontal = {
                width = 0.99,
                height = 0.95,
                preview_width = {0.33, min = 10},
            },
        },
        mappings = {
            i = {
                ["<F2>"] = "close",
            },
        },
    },
    pickers = {
        live_grep = {
            theme = "cursor",
            layout_config = {
                width = 0.99,
                height = 0.5,
                preview_width = {0.3, min = 10},
            },
        },
        buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            theme = "dropdown",
            layout_config = {
                width = 0.99,
                height = 0.7,
            },
            mappings = {
                i = {
                    ["<F4>"] = "close",
                    ["<c-d>"] = "delete_buffer",
                },
            },
        },
        lsp_document_symbols = {
            theme = "dropdown",
            show_line = true,
            symbols = {"function", "struct"},
            layout_config = {
                width = 0.9,
                height = 0.6,
            },
            mappings = {
                i = {
                    ["<F8>"] = "close",
                },
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
}

function vim.getVisualSelection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ''
    end
end

plugin.keys = {
    {"<c-p>", "<cmd>Telescope find_files<cr>"},
    {"<F2>", "<cmd>Telescope resume<cr>"},
    {"<F4>", "<cmd>Telescope buffers<cr>"},
    {"<F8>", "<cmd>Telescope lsp_document_symbols<cr>"},
    {"<leader>?", "<cmd>Telescope live_grep<cr>"},
    {"<leader>fw", function()
        local text = vim.fn.expand("<cword>")
        require("telescope.builtin").live_grep({default_text = text})
    end, mode = "n"},
    {"<leader>fw", function()
        local text = vim.getVisualSelection()
        require("telescope.builtin").live_grep({default_text = text})
    end, mode = "v"},
}

function plugin.config(_, opts)
    require('telescope').load_extension('fzf')
    -- We need to manually setup opts (plugin.opts) since we are overriding the config step
    require('telescope').setup(opts)
end

return plugin
