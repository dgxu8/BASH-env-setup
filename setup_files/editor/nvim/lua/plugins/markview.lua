-- Markdown & yaml/html viewer

local setup = function()
    require("markview").setup({
        markdown = {
            block_quotes = { wrap = false },
            headings = { org_indent_wrap = false },
            list_items = {
                wrap = false,
                shift_width = 2,
            },
        },
        preview = {
            icon_providers = "devicons",
            enable = false,
        },
    })
end

-- vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>Markview splitToggle<CR>", { desc = "Toggles `splitview` for current buffer." });
vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>Markview<CR>", { desc = "Toggles `markview` previews globally." });

return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {{"kyazdani42/nvim-web-devicons", version = false}},
    config = setup,
};
