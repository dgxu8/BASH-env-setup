local plugin = {"toppair/peek.nvim"}

plugin.event = {"VeryLazy"}

plugin.build = "deno task --quiet build:fast"

function plugin.config()
    require("peek").setup({
        theme = 'light',
    })
    -- refer to `configuration to change defaults`
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
end

return plugin
