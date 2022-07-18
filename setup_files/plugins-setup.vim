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
let g:esearch = {
      \ 'adapter':    'rg',
      \ 'backend':    'system',
      \ 'out':        'win',
      \ 'batch_size': 1000,
      \ 'wordchars': '@,48-57,_,192-255',
      \ 'prefill':        ['hlsearch', 'last'],
      \}

let g:esearch.root_markers = ['']
let g:esearch#out#win#open = 'vertical botright new'
let g:esearch#adapter#ag#options = "-U"
let g:esearch#util#trunc_omission = "|"
" }}}

" vim: set foldmethod=marker:

" minimap
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1
let g:minimap_width = 8
