set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
"source ~/.vimrc

" TODO: add python path maybe look at :help python-provider

"""""""""""" PLUGINS """""""""""
" Remember to run `:PlugInstall` after adding new ones
call plug#begin('~/.local/share/nvim/plugged')
Plug 'scrooloose/nerdtree' ", {'on':'NERDTeeToggle'}  allows a filetree on the side, loaded the first time it is used
Plug 'Xuyuanp/nerdtree-git-plugin' " Adds git info to nerdtree
" airline
" fzif
" colorscheme
Plug 'airblade/vim-gitgutter' " Add git info to the gutter, next to numbers
Plug 'w0rp/ale' " auto lints while typing. TODO: explore this more, lots of cool stuff
" Plug tpope/vim-surround " allows easy management of brackets, braces, etc.
" requires some learning...
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'majutsushi/tagbar'
" Plug lervag/vimtex "tex for vim, needs more investigation. Best option?
Plug 'edkolev/tmuxline.vim' " Puts vim statusline onto tmux statusline
Plug 'Yggdroot/indentLine' " Plugs little lines in for indentation
Plug 'ayu-theme/ayu-vim' " A color scheme

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
call plug#end()

"""""""""""" General Editor Settings """"""""""""
set mouse=a

set showmatch " highlight matching brackets
set number " show line numbers
set tabstop=4 " how big tabs are
set shiftwidth=4 " how much to shift with <> keys
set expandtab " use spaces instead of tabs

" split down and right
set splitbelow
set splitright

" set rnu " turns on relative numbering 

" use ; for :
nnoremap ; :

:set hidden " allows you to move from a buffer without saving it. 

:let mapleader = "'" "changing the leader key

""" Searching
set ignorecase " ignore case
set smartcase " pat attention to case if any caps present
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

""" Moving through buffers
:nnoremap <Tab> :bnext<CR>
:nnoremap <S-Tab> :bprevious<CR>

"""""""""""" Nerd tree commands """"""""""""
" autocmd vimenter * NERDTree " Automatically opens nerdtree

" Open nerdtree automatically if vim opens with no files:
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Open nerdtree automatically if we open vim with a folder:
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" Close vim if only window left is nerdtree:
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Nerdtree shortcut:
map <C-n> :NERDTreeToggle<CR>


"""""""""" Tagbar settings """""""""""""""
nmap <F8> :TagbarToggle<CR>
let g:tagbar_ctags_bin='/usr/local/bin/ctags'

"""""""""" Making it look good """""""""""

""" airline settings
let g:airline#extensions#tabline#enabled = 1 " Allows airline to show open buffers if there is only one tab
let g:airline_theme='simple' " Need to explore themes more

""" True colors
set termguicolors

""" load in color schem
let ayucolor='dark'
colorscheme ayu

""" indent guides
let g:indentLine_setColors = 0


""""""""" Easier navigation """""""""""
" all using fzf
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>s :Ag<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>m :Marks<CR>
"explore using for fuzzy finding
