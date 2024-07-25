-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- Color scheme
config.color_scheme = 'Ubuntu'
config.bold_brightens_ansi_colors = false
config.font = wezterm.font_with_fallback {'SauceCodePro Nerd Font Mono', 'Hack Nerd Font'}
config.font_size = 12
config.freetype_load_target = "Light"

-- Scrollback settings
config.enable_scroll_bar = true
config.scrollback_lines = 100000

config.window_padding = {
    top = "2px",
    bottom = 0,
}

local act = wezterm.action
config.keys = {}

for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = act.ActivateTab(i - 1),
    })
end

-- and finally, return the configuration to wezterm
return config
