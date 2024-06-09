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

local act = wezterm.action
config.keys = {
    -- Disable: Hide
    {key  = 'm', mods = 'SUPER', action = act.DisableDefaultAssignment},

    -- Disable: ToggleFullScreen
    {key  = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment},

    -- Disable: DecreaseFontSize
    {key  = '-', mods = 'SUPER', action = act.DisableDefaultAssignment},
    {key  = '-', mods = 'CTRL', action = act.DisableDefaultAssignment},

    -- Disable: IncreaseFontSize
    {key  = '=', mods = 'SUPER', action = act.DisableDefaultAssignment},
    {key  = '=', mods = 'CTRL', action = act.DisableDefaultAssignment},

    -- Disable: ResetFontSize
    {key  = '0', mods = 'SUPER', action = act.DisableDefaultAssignment},
    {key  = '0', mods = 'CTRL', action = act.DisableDefaultAssignment},

    -- Disable: CloseCurrentTab{confirm=true}
    {key  = 'w', mods = 'SUPER', action = act.DisableDefaultAssignment},
}

-- Rebind ActivateTab
for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = act.ActivateTab(i - 1),
    })
end

return config
