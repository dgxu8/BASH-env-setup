vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'

local setup = function()
    local langs = {
        "c", "cpp", "lua", "rust", "python",
        "yaml", "cmake", "vim", "vimdoc",
        "markdown", "markdown_inline", "rst",
        "udev", "xml", "html"
    }
    require("nvim-treesitter").install(langs)

    vim.api.nvim_create_autocmd('FileType', {
        pattern = langs,
        callback = function()
            -- vim.notify("filetype" .. vim.o.filetype, vim.log.levels.WARN)
            vim.treesitter.start()
        end,
    })

    -- highlight = {
    --     -- `false` will disable the whole extension
    --     enable = true,
    --
    --     -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    --     -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    --     -- the name of the parser)
    --     -- list of language that will be disabled
    --     disable = function(lang, buf)
    --         local max_filesize = 300 * 1024 -- 300 KB
    --         local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    --         if ok and stats and stats.size > max_filesize then
    --             return true
    --         end
    --     end,
    --
    --     -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    --     -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    --     -- Using this option may slow down your editor, and you may see some duplicate highlights.
    --     -- Instead of true it can also be a list of languages
    --     additional_vim_regex_highlighting = false,
    -- },
end

return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = setup,
    dependencies = {'nvim-treesitter/nvim-treesitter-textobjects'},
}
