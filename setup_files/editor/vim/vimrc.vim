"Source local settings if any.
if filereadable(glob("~/.vim/local-setup.vim"))
    source ~/.vim/local-setup.vim
endif

set nocompatible   " Use Vim settings, rather than Vi settings.

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif

" Set central backup and swap file locations.
if isdirectory($HOME . '/.vim/.backup') == 0
  :silent !mkdir -m 700 -p ~/.vim/.backup > /dev/null 2>&1
endif
set backupdir=~/.vim/.backup//

if isdirectory($HOME . '/.vim/.swp') == 0
  :silent !mkdir -m 700 -p ~/.vim/.swp > /dev/null 2>&1
endif
set directory=~/.vim/.swp//

set nowrap         " Don't wrap lines at the edge of the screen
set ruler          " show the cursor position in lower right corner all the time
set number         " Show line numbers
set history=50     " keep 50 lines of command line history
set showcmd        " display incomplete commands

set incsearch      " do incremental searching
set cursorline     " Highlight the current line

set hlsearch
set autoread       " Automatically update files if changed outside of Vim
set showmatch
set shiftwidth=4 tabstop=4 expandtab
set smarttab        " Treat shiftwidth spaces as a 'virtual tab' on empty lines.
                    " i.e. one backspace press will remove shiftwidth spaces and
                    " one tab press will insert shiftwidth spaces
set shiftround      " Round shift operators '>' and '<' to a multiple of shiftwidth

set wildmenu        " Show the completion menu
set wildmode=list:longest "A list of completions will be shown and the command
                          "will be completed to the longest common command.

set listchars=eol:¬,tab:\|\ ,trail:~,extends:>,precedes:<,nbsp:+
set list

set relativenumber

if has('gui_running')
    set guioptions-=T "remove toolbar
    set guioptions-=m "remove menu bar
endif

filetype plugin indent on

function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

augroup vimrc
autocmd!
    "Remove WS when a buffer is written
    autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

    " Treat WAF wscript as a python file
    autocmd BufNewFile,BufRead wscript* set filetype=python

    " Udev rules
    autocmd FileType hog set filetype=udevrules
augroup END

"map <F12> :buffers<BAR>
"           \let i = input("Buffer number: ")<BAR>
"           \execute "buffer " . i<CR>

map <C-p> :Files<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dennis Custom stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Get path
command GetPath :let @+ = expand("%:p") | echom @+

" folding settings
set foldenable
set foldlevelstart=99
set foldmethod=syntax
set ff=unix
set foldtext=substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'\ ...\ '.trim(getline(v:foldend)).'\ ('.(v:foldend-v:foldstart+1).'\ lines)'

set splitbelow
set splitright

set scrolloff=1  " Always show a line above/below cursor

" Same as above but from side to side
set sidescroll=1
set sidescrolloff=2

" For better scrolling on long blocks when we are wrapping text
set smoothscroll

" Auto set to mouse mode
set mouse=a

""""" Key remaps """""
" mouse mouse with <F2> and <F3>
"map <F2> :set mouse=a<CR>
"map! <F2> <C-O>:set mouse=a<CR>
"map <F3> :set mouse-=a<CR>
"map! <F3> <C-O>:set mouse-=a<CR>

" unhighlight search w/ space
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" added c-save
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>

" Search selection with //
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" map F4 to buffer explore
nmap <F4> :ToggleBufExplorer<CR>

" map F12 to close window
nmap <F12> :q<CR>

" Map F5 to change tab width to 2
nmap <F5> :set expandtab shiftwidth=2 tabstop=2 <CR>

" Map F6 to change tab width to 4
nmap <F6> :set expandtab shiftwidth=4 tabstop=4 <CR>

nmap <F7> :set noexpandtab shiftwidth=8 tabstop=8 <CR>

if &term =~ '256color'
        " Disable Background Color Erase (BCE) so that color schemes
        "     " work properly when Vim is used inside tmux and GNU screen.
        set t_ut=
endif

" override * so it doesn't jump to the new selection. Taken from: https://stackoverflow.com/a/49944815
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
map <leader>bd :Bclose<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LEADER MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Reload our .vimrc
nmap <leader>~ :source ~/.vimrc<CR>:redraw!<CR>:echo "~/.vimrc reloaded!"<CR>

" leader f to search for filename under cursor using fzf
"nnoremap <leader>f <Esc>:call fzf#vim#files('', {'options':'--query='.fzf#shellescape(expand('<cfile>:t'))})<CR>

" leader o to open directory of the current file.
nnoremap <leader>o <Esc>:exec "e " . expand('%:p:h')<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

nnoremap <A-a> <C-a>
nnoremap <A-x> <C-x>

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Remove suspending to terminal
nnoremap <C-z> <nop>

" Map Ctrl-Backspace to delete the previous word in insert mode. We
" need to use <C-H> because Ctrl-backspace is not a recongized keycode
" and share the same mapping as ctrl-h.
imap <C-H> <C-W>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction
