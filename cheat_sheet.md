# Bash

## fzf - fuzzy finder
`fzf` - launch fuzzy finder
`Ctrl+t` - launch fzf in instance
`Ctrl+j` - move down
`Ctrl+k` - move up

`:Files` - start fzf

# Vim 

## Undo / Redo
`u` - undo in normal mode
`Ctrl+r` - redo

## Movement
`w` - move right one word
`b` - move left one word

## Search
`*` search for selected word
`/pattern` search forwards
`n` for next found
`space` to remove highlighting

## Folding
To fold use `za` to fold a selected area.

## Better Column select (normal mode only)
`Ctrl-n` - repeated presses selects more.
`c` replaces
`I` inserts at front
`A` inserts at end

## Column select

1. `Ctrl + V` to go into column mode
2. `Shift + i` to go into insert mode
3. `Esc` to apply

## Copy & Paste

1. `v`, `V`, or `Ctrl-v` for selection. v:char, V:line, Crtl-v:Block
2. `y` to copy. `d` to cut.
3. `p` to paste after cursor. `P` to paste before cursor

# Tmux

## Source config file
`tmux source-file ~/.tmux.conf`

## Start new session
`tmux new -s [session name]`

## Re-open session
`tmux a -t [session name]`

## Kill session 
`tmux kill-session -a/-t [name of session]`

## List tmux sessions
`tmux ls`

## Exit modes
`q` - exits the mode, mashing Esc can also work.

## Scroll terminal
Ctrl-a + [

## Detach
Ctrl-a + d

## Big clock
Ctl-a + t

# Markdown

## Code block language
use ``` to block comment into a language

# MDV
mdv *file* -t *theme* 
Themes *Value located in: *:

- 528.9419 : warm
- 546.7068 : shades of cool

# vim-plug
`:PlugInstall` - installs vim-plug pluggins 
