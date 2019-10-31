set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
"source ~/.vimrc

" TODO: add python path maybe look at :help python-provider

"changing the leader key
let mapleader = "'"


"""""""""""" PLUGINS """""""""""
" Remember to run `:PlugInstall` after adding new ones
call plug#begin('~/.local/share/nvim/plugged')
Plug 'scrooloose/nerdtree' ", {'on':'NERDTeeToggle'}  allows a filetree on the side, loaded the first time it is used
Plug 'Xuyuanp/nerdtree-git-plugin' " Adds git info to nerdtree
" colorscheme
Plug 'airblade/vim-gitgutter' " Add git info to the gutter, next to numbers

Plug 'tpope/vim-fugitive'


Plug 'w0rp/ale' " auto lints while typing. TODO: explore this more, lots of cool stuff
" Plug tpope/vim-surround " allows easy management of brackets, braces, etc.
" requires some learning...
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'majutsushi/tagbar'
" Plug lervag/vimtex "tex for vim, needs more investigation. Best option?
Plug 'edkolev/tmuxline.vim' " Puts vim statusline onto tmux statusline
"Plug 'Yggdroot/indentLine' " Plugs little lines in for indentation requires
"conceal line, which generally screws up a lot of other stuff
" Plug 'ayu-theme/ayu-vim' "  A color scheme
" Plug 'NLKNguyen/papercolor-theme'
"Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'NLKNguyen/papercolor-theme'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'christoomey/vim-tmux-navigator'

Plug 'lervag/vimtex'

Plug 'scrooloose/nerdcommenter'

"" YCM:
"Plug 'Valloric/YouCompleteMe' "Lol, this doesn't do anything
" Installing has to be done by a messing compilation. It does
" too much.
"""""""""""""""""""

"TODO: Try out Jedi-vim and ncm2;q
"TODO: does this conflict with ale?

"" COC:
"Plug 'neoclide/coc.nvim', {'branch':'release'} Too much work to setup
" and uses json and stuff. Essentially it rolls vs code into here,
" preventing good config files and stuff. Not a fan
""""""""""""""""""""

"" Deoplete:
" so long as I use python 2, this isn't a viable option:
"Plug 'Shougo/deoplete.nvim',{'do':':UpdateRemotePlugins'}
"Plug 'deoplete-plugins/deoplete-jedi' " requires: pip install jedi
"Plug 'lionawurscht/deoplete-biblatex'
"Plug 'deoplete-plugins/deoplete-zsh'
"" requires typescript to be installed (npm -g install typescript) or
"" locally in your node modules
"Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
""""""""""""""""""""

"Plug 'taketwo/vim-ros' " doesn't work with modern vim, needs python2
Plug 'heavenshell/vim-pydocstring'

Plug 'rhysd/vim-grammarous'
Plug 'davidbeckingsale/writegood.vim'

Plug 'pangloss/vim-javascript'
"Plug 'mxw/vim-jsx' having trouble with this one in jsx
Plug 'MaxMEllon/vim-jsx-pretty'

Plug 'leafgarland/typescript-vim'
Plug 'HerringtonDarkholme/yats.vim'

" Maintaining tags files, probably only want one of these:
Plug 'ludovicchabant/vim-gutentags'
" Plug LucHermitte/lh-tags
" Plug soramugi/auto-ctags.vim
"

"" Markdown
" will install npm+yarn:
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
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


""" Searching
set ignorecase " ignore case
set smartcase " pat attention to case if any caps present
" Use <C-L> to clear the highlighting of :set hlsearch.
" if maparg('<C-L>', 'n') ==# ''
"   nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
" endif

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
" let g:airline_theme='simple' " Need to explore themes more

""" True colors
set termguicolors

""" load in color schem
" let ayucolor='dark'
" set background=dark
"colorscheme onehalfdark
"let g:airline_theme='onehalfdark'
"let g:color_mode = 'dark'

"colorscheme onehalflight
"let g:airline_theme='onehalflight'
"let g:color_mode = 'light'

"function! FlipColor()
    "if g:color_mode=='dark'
        "colorscheme onehalflight
        ""let g:airline_theme='onehalflight'
        "let g:color_mode='light'
    "elseif g:color_mode=='light'
        "colorscheme onehalfdark
        ""let g:airline_theme='onehalfdark'
        "let g:color_mode='dark'
    "endif
"endfunction

"command! ToggleColor call FlipColor()

set background=dark
colorscheme PaperColor
""" indent guides
let g:indentLine_setColors = 0


""""""""" Easier navigation """""""""""
" all using fzf
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>s :Ag<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>m :Marks<CR>
nnoremap <Leader>t :Tags<CR>

"explore using for fuzzy finding

""""""""" Easier pane nav """"""""""""
map <C-h> <C-W>h
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l

""""""""" NVR """""""""""
"" Set nvr for git commits and the like
if has('nvim')
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif
" if doing a git commit, auto close buffer
autocmd FileType gitcommit set bufhidden=delete

" to use from regular shell: `git config --global core.editor 'nvr
" --remote-wait-silent'`

"""""" LaTeX """""""""""""
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_method = 'zathura'

"""""" Commmenting """"""
" this is needed for nerd commenter to know what is up:
filetype plugin on

au BufNewFile,BufRead *.launch setf launch

    let g:NERDCustomDelimiters = {
        \ 'launch': { 'left': '<!--', 'right': '-->' },
    \ }

"""""" spelling """"""
let g:spelling_state = 'off'

function! FlipSpelling()
    if g:spelling_state=='off'
        set spell spelllang=en_us
        let g:spelling_state = 'on'
    elseif g:spelling_state=='on'
        set nospell
        let g:spelling_state = 'off'
    endif
endfunction

command! ToggleSpelling call FlipSpelling()

""""" Linting with ale """"'
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1 " don't want to mess with ycm
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'python': ['autopep8'],
            \ 'javascript': ['prettier'],
            \ 'typescript': ['prettier'],
            \ 'cpp':['clang-format'],
            \}
let g:ale_linters = {
            \'python':['flake','pylint'],
            \'latex':['alex','chktex','proselint','lacheck'],
            \'markdown':['alex','proselint'],
            \'javascript': ['eslint'],
            \'typescript': ['eslint']
            \}

let g:ale_linter_aliases = {
            \'jsx': 'javascript',
            \'tsx': 'typescript',
            \'arduino':'cpp'
            \}

nmap <silent> <leader>a :ALENext<cr>
nmap <silent> <leader>A :ALEPrevious<cr>
let g:airline#extensions#ale#enabled = 1

let g:ale_echo_msg_format = '[%linter%] %s'
"To fix problems with over eagerly inserting text:
set completeopt=menu,menuone,preview,noselect,noinsert
"let g:ale_set_ballons = 1 "should allow info to pop up when hovering
let g:ale_close_preview_on_insert = 1  "closes the ale preview when in insert mode
let g:ale_cursor_detail = 0 "shows the error in a window when hovering
                            "don't want this. prefer error in airline
                            "status


""""" Py Doc Sting """""
nmap <silent> <Leader-d> <Plug>(pydocstring)
let g:pydocstring_templates_dir = '~/Documents/git/config_files/nvim/pydoc-templates'


""""" Tag setup """""
"" Use ctrl-] to jump to a definition
"set tags=~/mytags

" generate new tags: ctags -R
"
""""" Copy and past with system clipboard """"
set clipboard=unnamedplus

"""" Reload files from disk on change """"
set autoread
au CursorHold,CursorholdI * :checktime
au FocusGained,BufEnter * :checktime

"""" Improving Prose """"
"" Vim-wordy
"" Vim-grammarous (language tool)
:nmap <F5> <Plug>(grammarous-move-to-next-error)
:nmap <F6> <Plug>(grammarous-move-to-info-window)
":nmap <F7> <Plug>(grammarous-close-info-window)
"let g:grammarous#use_location_list=1

" this sets up the basics on its own. There is still more to play with
"" Vim-languagetool (language tool)
"grammarous is far better
"" alex (insensitive words)
"" just say no (hedge words)
"" write good (everything)
"" proselint (quality of prose)
"" vale (multi-purpose, can include above)
"" textlint (like vale)
"" coala (like vale)

"""" Deoplete for autocomplete """"
let g:deoplete#enable_at_startup = 1
