-- Keybinds to work with navigator.nvim which allows for seamless pane switching
local w = require 'wezterm'
local a = w.action

local function is_inside_vim(pane)
    local tty = pane:get_tty_name()
    if tty == nil then return false end

    local success, stdout, stderr = w.run_child_process
        { 'sh', '-c',
        'ps -o state= -o comm= -t' .. w.shell_quote_arg(tty) .. ' | ' ..
        'grep -iqE \'^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$\'' }

    return success
end

local function is_outside_tmux(pane)
    -- w.log_info(pane:get_user_vars())
    return pane:get_user_vars().WEZTERM_IN_TMUX == "0"
end

local function is_no_foreground(pane)
    -- w.log_info(pane:get_user_vars())
    return pane:get_user_vars().WEZTERM_PROG == ""
end

local function is_outside_vim(pane) return not is_inside_vim(pane) end

local function tmux_foreground_shared(key, mods, action)
    local function callback(win, pane)
        if is_outside_tmux(pane) and is_no_foreground(pane) then
            win:perform_action(action, pane)
        else
            win:perform_action(a.SendKey({key=key, mods=mods}), pane)
        end
    end
    return {key=key, mods=mods, action=w.action_callback(callback)}
end

local function vim_shared(key, mods, action)
    local function callback (win, pane)
        if is_outside_vim(pane) then
            win:perform_action(action, pane)
        else
            win:perform_action(a.SendKey({key=key, mods=mods}), pane)
        end
    end

    return {key=key, mods=mods, action=w.action_callback(callback)}
end

return tmux_foreground_shared
