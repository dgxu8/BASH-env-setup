-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = 'Ubuntu'
config.font = wezterm.font_with_fallback {'SauceCodePro Nerd Font', 'ProFont IIx Nerd Font'}
config.font_size = 11.5

-- Scrollback settings
config.enable_scroll_bar = true
config.scrollback_lines = 100000

-- Pull in keybind helpers
local vim_shared = require 'vim_bind_helper'

local act = wezterm.action
config.leader = { key = "a", mods = 'CTRL'}
config.keys = {
    {
        key  = '-',
        mods = 'LEADER',
        action = act{SplitVertical={domain='CurrentPaneDomain'}},
    },
    {
        key  = '|',
        mods = 'LEADER|SHIFT',
        action = act{SplitHorizontal={domain='CurrentPaneDomain'}},
    },
    {
        key = '[',
        mods = 'LEADER',
        action = act.ActivateCopyMode,
    },
}

table.insert(config.keys, vim_shared('h', 'CTRL', act.ActivatePaneDirection('Left')))
table.insert(config.keys, vim_shared('j', 'CTRL', act.ActivatePaneDirection('Down')))
table.insert(config.keys, vim_shared('l', 'CTRL', act.ActivatePaneDirection('Right')))
table.insert(config.keys, vim_shared('k', 'CTRL', act.ActivatePaneDirection('Up')))
table.insert(config.keys, vim_shared('PageUp', '', act.ScrollByPage(-0.9)))
table.insert(config.keys, vim_shared('PageDown', '', act.ScrollByPage(0.9)))

for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = act.ActivateTab(i - 1),
    })
end

return config
