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
Plug 'ryanoasis/vim-devicons' " needs a nerdtre font

Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim' " for viewing commit tree, :GV to view :GV! for commits on this file


Plug 'w0rp/ale' " auto lints while typing. TODO: explore this more, lots of cool stuff
Plug 'tpope/vim-surround' " allows easy management of brackets, braces, etc.
" requires some learning...
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'majutsushi/tagbar'
Plug 'edkolev/tmuxline.vim' " Puts vim statusline onto tmux statusline
Plug 'NLKNguyen/papercolor-theme'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'christoomey/vim-tmux-navigator'

Plug 'lervag/vimtex'

Plug 'scrooloose/nerdcommenter'

Plug 'heavenshell/vim-pydocstring'

Plug 'rhysd/vim-grammarous' " need to call to hit the server manually
Plug 'davidbeckingsale/writegood.vim'

Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'

Plug 'leafgarland/typescript-vim'
Plug 'HerringtonDarkholme/yats.vim' " yet another typescript plugin

" Maintaining tags files, probably only want one of these:
Plug 'ludovicchabant/vim-gutentags'

Plug 'ekalinin/Dockerfile.vim'

Plug 'jceb/vim-orgmode'

Plug 'jalvesaq/Nvim-R'
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
set rnu

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

"""""""""""" Nerd Tree """"""""""""
" Close vim if only window left is nerdtree:
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Nerdtree shortcut:
function! NERDTreeFindToggle()
    if exists("g:NERDTree") && g:NERDTree.IsOpen()
        :NERDTreeToggle
    else
        :NERDTreeFind
    endif
endfunction
nnoremap <C-n> :call NERDTreeFindToggle()<CR>

"remove ? note
let NERDTreeMinimalUI = 1


"""""""""" Tagbar settings """""""""""""""
nmap <F8> :TagbarToggle<CR>
let g:tagbar_ctags_bin='/usr/local/bin/ctags'

"""""""""" gutentags settings """"""""""""
" Keep the tag files out of the projects:
let g:gutentags_cache_dir='/tmp/gutentags/'

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
"nnoremap <Leader>t :Tags<CR> " this will search ALL tags in session
" this will search the tags in the curent file:
nnoremap <Leader>t :BTags<CR>

"Make AG only search contents not names (https://github.com/junegunn/fzf.vim/issues/346):
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Have a history for fzf, use ctrl-n and ctrl-p
let g:fzf_history_dir = '~/.local/share/fzf-history'

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
let g:ale_completion_enabled = 1
let g:ale_linters_explicit=1
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'python': ['autopep8'],
            \ 'javascript': ['prettier'],
            \ 'typescript': ['prettier'],
            \ 'typescriptreact': ['prettier'],
            \ 'cpp':['clang-format'],
            \ 'tex':['latexindent'],
            \ 'markdown':['prettier'],
            \ 'yaml':['prettier']
            \}

" This will make prettier always wrap text:
let b:ale_javascript_prettier_options = '--prose-wrap always'
"Prettier is needed for js/tsx: https://prettier.io/docs/en/install.html
"I was using Alex in a few places to find insensitive words, but it was annoying as hell
let g:ale_linters = {
            \'python':['flake','pylint','pyls'],
            \'tex':['chktex','proselint','lacheck', 'writegood'],
            \'markdown':['proselint', 'writegood', 'remark_lint'],
            \'javascript': ['eslint'],
            \'typescript': ['eslint'],
            \ 'typescriptreact': ['eslint'],
            \ 'yaml':['yamllint'],
            \}

let g:ale_linter_aliases = {
            \'jsx': 'javascript',
            \'tsx': 'typescript',
            \'arduino':'cpp',
            \'plaintex':'tex',
            \'latex':'tex',
            \}

nmap <silent> ]a :ALENext<cr>
nmap <silent> [a :ALEPrevious<cr>
nmap <silent> <Leader>h <Plug>(ale_hover)

let g:airline#extensions#ale#enabled = 1

let g:ale_echo_msg_format = '[%linter%] %s'
"To fix problems with over eagerly inserting text:
set completeopt=menu,menuone,preview,noselect,noinsert
"let g:ale_set_ballons = 1 should allow info to pop up when hovering
let g:ale_close_preview_on_insert = 0  "closes the ale preview when in insert mode
let g:ale_cursor_detail = 0 "shows the error in a window when hovering
                            "don't want this. prefer error in airline
                            "status


""""" Py Doc Sting """""
nmap <silent> <Leader>d <Plug>(pydocstring)
let g:pydocstring_templates_dir = '~/Documents/git/config_files/nvim/pydoc-templates'

""""" Copy and past with system clipboard """"
set clipboard=unnamedplus

"""" Reload files from disk on change """"
set autoread
au CursorHold,CursorholdI * :checktime
au FocusGained,BufEnter * :checktime

"""" Improving Prose """"
"" Vim-wordy
"" Vim-grammarous (language tool)
:nmap <silent> ]g <Plug>(grammarous-move-to-next-error)
:nmap <silent> [g <Plug>(grammarous-move-to-previous-error)
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


"""" git """"
set updatetime=100 "" will make guttertags show up faster
" for jumping between hunks using more obvious commands
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

"""" NVIM-R """"
let R_in_buffer = 0
let R_source = '/home/mjsobrep/.local/share/nvim/plugged/Nvim-R/R/tmux_split.vim'
