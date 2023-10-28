# Usefull keybinds/commands

## Telescope
- `<C-q>` puts search into quickfix list
- `<leader>fw` search for word/selection
- `<leader>?` empty search

## Treesitter
- `:Inspect` to show the highlight groups under the cursor
- `:InspectTree` to show the parsed syntax tree ("TSPlayground")
- `:EditQuery` to open the Live Query Editor (Nvim 0.10+)

## Gitgutter
- `[c` | `]c` Go between hunks
- `<leader>hs` Stage hunk
- `<leader>hu` Unstage hunk

## Surround
Closed `]`, `}`, and `)` for no spaces
- `cs'"` Changes `'` to `"`
- `ysiw}` Adds "{}" around word

## Vim multi
- `<C-N>` select words
- `<C-Down>` or `<C-up>` create cursors vertically
- `<Shift-Arrows>`select one character at a time
- press `n` or `N` to get next/previous occurrence
- press `[` or `]` to select next/previous cursor
- press `q` to skip current and get next occurrence
- press `Q` to remove current cursor/selection
- start insert mode with `i`, `a`, `I`, `A`
- `<leader>A` Select all words in file

## nvim-cmp
- `<C-p>` cmp.mapping.select_prev_item(select_opts)
- `<C-n>` cmp.mapping.select_next_item(select_opts)
- `<C-d>` cmp.mapping.scroll_docs(-4)
- `<C-f>` cmp.mapping.scroll_docs(4)
- `<C-Space>` cmp.mapping.complete()
- `<C-e>` cmp.mapping.abort()
