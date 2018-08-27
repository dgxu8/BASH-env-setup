set nocompatible

filetype off

" load plugins here

syntax on

filetype plugin indent on

set smartcase

set modelines=0
set number
set ruler
set visualbell

set wrap
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'nightsense/snow'

" plug in fzf
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" save with crtl-s
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>

" mouse mouse with <F2> and <F3>
map <F2> :set mouse=a<CR>
map! <F2> <C-O>:set mouse=a<CR>
map <F3> :set mouse-=a<CR>
map! <F3> <C-O>:set mouse-=a<CR>

" map for fzf
map ; :Files<CR>

" map for file tree
map <C-o> :NERDTreeToggle<CR>

" turn on search highlighting
set hlsearch

" map space to get rid of highlighting
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Fold settings
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

" recongize .md as markdown
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" enable lightline
set laststatus=2

" enable snow color scheme
set background=dark
colorscheme snow

" The following settings might need to be enabled for wsl terminals
"set term=screen-256color
"set t_ut=
