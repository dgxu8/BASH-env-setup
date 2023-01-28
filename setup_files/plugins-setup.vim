"Plugins Setup

" {{{ ack.vimx
" Vim plugin for the Perl module / CLI script 'ack'
" Can also be used with ag.
if executable('ag')
    let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
endif

cnoreabbrev ag Ack
cnoreabbrev aG Ack
cnoreabbrev Ag Ack
cnoreabbrev AG Ack

" {{{ vim-esearch
" NeoVim/Vim plugin performing project-wide async search and replace, similar to SublimeText, Atom et al.
let g:esearch = {}
let g:esearch.regex = 1
let g:esearch.case = 'smart'
let g:esearch.backend = 'nvim'
let g:esearch.out = 'qflist'
let g:esearch.prefill = ['hlsearch', 'last']
let g:esearch.adapter = 'rg'
let g:esearch.root_markers = ['']
let g:esearch.name = '[esearch]'
let g:esearch.win_new = {esearch -> esearch#buf#goto_or_open(esearch.name, 'vnew')}
let g:esearch#adapter#ag#options = '-U'
let g:esearch#util#trunc_omission = '|'
" }}}

" vim: set foldmethod=marker:

" minimap
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1
let g:minimap_width = 8

" Setup oceanic-next colorscheme
if (has("termguicolors"))
  set termguicolors
endif

syntax on
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
colorscheme OceanicNext
