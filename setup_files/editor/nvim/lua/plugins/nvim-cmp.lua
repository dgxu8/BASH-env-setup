return {
    {
        "hrsh7th/nvim-cmp",

        version = false,
        event = "InsertEnter",

        dependencies = {
            -- sources
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",

            -- cmp icons
            "onsails/lspkind-nvim",

            -- snippets
            "l3mon4d3/luasnip",
            "rafamadriz/friendly-snippets",

            -- completion scores
            "p00f/clangd_extensions.nvim",
        },

        opts = function ()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local auto_select = false

            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

            -- customization for pmenu
            vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#454952", fg = "NONE" })
            vim.api.nvim_set_hl(0, "Pmenu", { fg = "#C5CDD9", bg = "#31353f" })

            vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
            vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

            -- Set icon color
            vim.api.nvim_set_hl(0, "CmpItemKindFieldIcon", { fg = "#EED8DA", bg = "#B5585F" })
            vim.api.nvim_set_hl(0, "CmpItemKindPropertyIcon", { fg = "#EED8DA", bg = "#B5585F" })
            vim.api.nvim_set_hl(0, "CmpItemKindEventIcon", { fg = "#EED8DA", bg = "#B5585F" })

            vim.api.nvim_set_hl(0, "CmpItemKindTextIcon", { fg = "#C3E88D", bg = "#9FBD73" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnumIcon", { fg = "#C3E88D", bg = "#9FBD73" })
            vim.api.nvim_set_hl(0, "CmpItemKindKeywordIcon", { fg = "#C3E88D", bg = "#9FBD73" })

            vim.api.nvim_set_hl(0, "CmpItemKindConstantIcon", { fg = "#FFE082", bg = "#D4BB6C" })
            vim.api.nvim_set_hl(0, "CmpItemKindConstructorIcon", { fg = "#FFE082", bg = "#D4BB6C" })
            vim.api.nvim_set_hl(0, "CmpItemKindReferenceIcon", { fg = "#FFE082", bg = "#D4BB6C" })

            vim.api.nvim_set_hl(0, "CmpItemKindFunctionIcon", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindStructIcon", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindClassIcon", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindModuleIcon", { fg = "#EADFF0", bg = "#A377BF" })
            vim.api.nvim_set_hl(0, "CmpItemKindOperatorIcon", { fg = "#EADFF0", bg = "#A377BF" })

            vim.api.nvim_set_hl(0, "CmpItemKindVariableIcon", { fg = "#C5CDD9", bg = "#7E8294" })
            vim.api.nvim_set_hl(0, "CmpItemKindFileIcon", { fg = "#C5CDD9", bg = "#7E8294" })

            vim.api.nvim_set_hl(0, "CmpItemKindUnitIcon", { fg = "#F5EBD9", bg = "#D4A959" })
            vim.api.nvim_set_hl(0, "CmpItemKindSnippetIcon", { fg = "#F5EBD9", bg = "#D4A959" })
            vim.api.nvim_set_hl(0, "CmpItemKindFolderIcon", { fg = "#F5EBD9", bg = "#D4A959" })

            vim.api.nvim_set_hl(0, "CmpItemKindMethodIcon", { fg = "#DDE5F5", bg = "#6C8ED4" })
            vim.api.nvim_set_hl(0, "CmpItemKindValueIcon", { fg = "#DDE5F5", bg = "#6C8ED4" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnumMemberIcon", { fg = "#DDE5F5", bg = "#6C8ED4" })

            vim.api.nvim_set_hl(0, "CmpItemKindInterfaceIcon", { fg = "#D8EEEB", bg = "#58B5A8" })
            vim.api.nvim_set_hl(0, "CmpItemKindColorIcon", { fg = "#D8EEEB", bg = "#58B5A8" })
            vim.api.nvim_set_hl(0, "CmpItemKindTypeParameterIcon", { fg = "#D8EEEB", bg = "#58B5A8" })

            -- Set kind string color's text to match background from icon
            vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#B5585F", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#B5585F", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#B5585F", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#9FBD73", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#9FBD73", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#9FBD73", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#D4BB6C", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = "#D4BB6C", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = "#D4BB6C", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#A377BF", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#A377BF", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#A377BF", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#A377BF", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = "#A377BF", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#7E8294", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#7E8294", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = "#D4A959", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#D4A959", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#D4A959", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#6C8ED4", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#6C8ED4", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#6C8ED4", bg = "NONE" })

            vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#58B5A8", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#58B5A8", bg = "NONE" })
            vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = "#58B5A8", bg = "NONE" })

            local has_words_before = function()
                if vim.api.nvim_get_option_value("buftype", {}) == "prompt" then return false end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
            end

            return {
                auto_brackets = {},
                completion = {
                    completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
                },
                preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
                mapping = {
                    ["<c-p>"] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}),
                    ["<c-n>"] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}),
                    ["<c-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<c-f>"] = cmp.mapping.scroll_docs(4),
                    ["<c-Space>"] = cmp.mapping.complete(),
                    ["<c-e>"] = cmp.mapping.abort(),
                    ["<cr>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    },
                    ["<tab>"] = vim.schedule_wrap(function(fallback)
                        if cmp.visible() and has_words_before() then
                            cmp.select_next_item({behavior = cmp.SelectBehavior.Select})
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end),
                    ["<S-tab>"] = vim.schedule_wrap(function(fallback)
                        if cmp.visible() and has_words_before() then
                            cmp.select_prev_item({behavior = cmp.SelectBehavior.Select})
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end),
                },
                sources = cmp.config.sources ({
                    {name = "nvim_lsp"},
                    {name = "path"},
                }, {
                    {name = "buffer", keyword_length = 3},
                    {name = "luasnip", keyword_length = 2},
                }),
                formatting = {
                    fields = { "icon", "abbr", "kind" },
                    format = function(entry, item)
                        local icons = require("lspkind").cmp_format({
                            mode = "symbol_text", maxwith = 100
                        })(entry, item)
                        icons.icon = " " .. (icons.icon or "") .. " "
                        icons.kind = "    (" .. (icons.kind or "") .. ")"

                        -- IDK what this "if" is used for
                        if icons[item.icon] then
                            item.icon = icons[item.icon] .. item.icon
                        end

                        -- Abbreviating the name if it's too long
                        local widths = {
                            abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 70,
                            menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 70,
                        }

                        for key, width in pairs(widths) do
                            if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
                            end
                        end

                        return item
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered({
                        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:Visual,Search:None",
                        col_offset = -3,
                        side_padding = 0,
                        border = 'rounded',
                    }),
                    documentation = cmp.config.window.bordered({
                        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:Visual,Search:None",
                        border = 'rounded',
                    }),
                },
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.recently_used,
                        require("clangd_extensions.cmp_scores"),
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
            }
        end,
    },
}
