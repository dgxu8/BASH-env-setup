local plugins = {
    {"tpope/vim-fugitive"},
    {"airblade/vim-gitgutter"},
    {"petertriho/nvim-scrollbar", config = true},
    {"mg979/vim-visual-multi"},
    {"tpope/vim-surround"},
    {"kyazdani42/nvim-web-devicons", lazy = true},
    {"christoomey/vim-tmux-navigator"},
    {"kergoth/vim-bitbake"},
    {"folke/neodev.nvim", opts = {}},
}

-- vim visual multi color mode
vim.api.nvim_command("let g:VM_theme = 'iceblue'")

return plugins
