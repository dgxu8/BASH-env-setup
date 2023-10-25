local plugin = {"EdenEast/nightfox.nvim"}

plugin.opts = {
    palettes = {
        -- Lighten up colors
        carbonfox = {
            bg0 = "#161616",
            bg1 = "#252525",
            bg2 = "#323232",
            bg3 = "#383838",
            bg4 = "#727274",
            fg0 = "#f9fbff",
            fg1 = "#f2f4f8",
            fg2 = "#c5c6c9",
            fg3 = "#98999a",
            sel0 = "#545454",
            comment = "#a5a6a7",
            pink = "#ff5fae",
            teal = "#14cccc",
            red = {
                base = "#ff0000",
                bright = "#9d1212",
                dim = "#d04545",
            },
            orange = {
                base = "#ff811a",
                bright = "#ff9b34",
                dim = "#eb6a00",
            },
            yellow = {
                base = "#ffff39",
                bright = "#fff41f",
                dim = "#cdc200",
            },
            blue = {
                base = "#0ba1fe",
                bright = "#25bbff",
                dim = "#0088e5",
            },
        },
    },
    specs = {
        carbonfox = {
            syntax = {
                preproc = "red.dim",
                include = "red.dim",
                string = "green.bright",
                builtin0 = "#d63395",
                builtin1 = "#eb9500",
                builtin2 = "teal",
                number = "cyan",
                const = "teal",
                type = "orange.dim",
                func = "#8fe260",
                operator = "#808080",
            },
        },
    },
    groups = {
        all = {
            ["@parameter"] = { link = "variable" },
            Whitespace = { link = "comment" },
        },
    },
    options = {
        dim_inactive = true,
        styles = {
            comments = "italic",
        },
    },
}

function plugin.init()
    vim.cmd("colorscheme carbonfox")
end

return plugin
