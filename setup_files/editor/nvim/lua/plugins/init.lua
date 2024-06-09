local plugins = {
    {"tpope/vim-fugitive"},
    {"petertriho/nvim-scrollbar", config = true},
    {"tpope/vim-surround"},
    {"kyazdani42/nvim-web-devicons", lazy = true},
    {"kergoth/vim-bitbake"},
--    {"folke/neodev.nvim", opts = {}},
    {"numToStr/Comment.nvim", config = true, keys = {{"gc", mode = {"n", "x"}}, {"gb", mode = {"n", "x"}}}},
}

return plugins
