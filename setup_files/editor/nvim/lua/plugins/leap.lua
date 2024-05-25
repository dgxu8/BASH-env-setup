local plugin = {"ggandor/leap.nvim"}

plugin.dependencies = {
    {"tpope/vim-repeat"},
}

plugin.enabled = true

plugin.keys = {
    { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
    { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
    { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
}

function plugin.config(_, opts)
    local leap = require("leap")
    leap.create_default_mappings()
    for k, v in pairs(opts) do
        leap.opts[k] = v
    end
    leap.opts.highlight_unlabeled_phase_one_targets = true
    leap.opts.special_keys.prev_target = '<backspace>'
    leap.opts.special_keys.prev_group = '<backspace>'
end

return plugin
