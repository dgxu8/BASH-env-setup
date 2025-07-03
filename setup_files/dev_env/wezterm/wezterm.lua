-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Color scheme
config.color_scheme = 'Ubuntu'
config.bold_brightens_ansi_colors = false
config.font = wezterm.font_with_fallback {'SauceCodePro Nerd Font Mono', 'Hack Nerd Font'}
config.font_size = 12
config.freetype_load_target = "Light"

config.warn_about_missing_glyphs = false

-- Scrollback settings
config.enable_scroll_bar = true
config.scrollback_lines = 100000

config.window_padding = {
    top = "2px",
    bottom = 0,
}

local tmux_foreground_shared = require 'vim_bind_helper'

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

table.insert(config.keys, tmux_foreground_shared('PageUp', '', act.ScrollByPage(-0.9)))
table.insert(config.keys, tmux_foreground_shared('PageDown', '', act.ScrollByPage(0.9)))

-- Rebind ActivateTab
for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = act.ActivateTab(i - 1),
    })
end

return config
