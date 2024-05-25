vim.api.nvim_command("source ~/.vim/vimrc.vim")

vim.keymap.set("n", "<F9>", "<cmd>split term://bash<cr>")
vim.keymap.set("t", "<F9>", "<cmd>q<cr>")
vim.keymap.set("t", "<ESC>", "<c-\\><c-n>")

vim.o.fillchars="fold: "
vim.o.foldnestmax = 3
vim.o.foldminlines = 1
vim.o.jumpoptions = "stack"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
