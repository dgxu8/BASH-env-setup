local plugin = { url = "https://codeberg.org/andyg/leap.nvim" }

plugin.dependencies = {
    {"tpope/vim-repeat"},
}

plugin.enabled = true

vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')

function plugin.config()
    -- Highly recommended: define a preview filter to reduce visual noise
    -- and the blinking effect after the first keypress
    -- (see `:h leap.opts.preview`).
    -- For example, skip preview if the first character of the match is
    -- whitespace or is in the middle of an alphabetic word:
    require('leap').opts.preview = function(ch0, ch1, ch2)
        return not (
            ch1:match('%s')
            or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
        )
    end

    -- Define equivalence classes for brackets and quotes, in addition to
    -- the default whitespace group:
    require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

    -- Use the traversal keys to repeat the previous motion without
    -- explicitly invoking Leap:
    require('leap.user').set_repeat_keys('<enter>', '<backspace>')

    -- Automatic paste after remote yank operations:
    vim.api.nvim_create_autocmd('User', {
        pattern = 'RemoteOperationDone',
        group = vim.api.nvim_create_augroup('LeapRemote', {}),
        callback = function(event)
            if vim.v.operator == 'y' and event.data.register == '"' then
                vim.cmd('normal! p')
            end
        end,
    })
end

return plugin
