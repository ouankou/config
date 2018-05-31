set nocompatible
filetype off
set rtp+=$HOME/.vim/bundle/vundle/
let path='$HOME/.vim/bundle'
call vundle#rc('$HOME/.vim/bundle')

Bundle 'gmarik/vundle'

let os = substitute(system('uname'), '\n', '', '')
if os == 'Linux'
    "set guifont=FreeMono\ Regular\ 16
    set guifont=WenQuanYi\ Micro\ Hei\ Mono\ Regular\ 14
else
    set guifont=Source\ Code\ Pro:h18
endif

"Bundle 'jcf/vim-latex'
Bundle 'scrooloose/nerdtree'
Bundle 'Yggdroot/indentLine'
Bundle 'tomasr/molokai'
Bundle 'altercation/vim-colors-solarized'
"Bundle 'altercation/solarized'
Bundle 'scrooloose/syntastic'
"Bundle 'jalvesaq/Nvim-R'
"Bundle 'Vim-R-plugin'
"Bundle 'jalvesaq/VimCom'
"Bundle 'jalvesaq/R-Vim-runtime'
Bundle 'jalvesaq/colorout'
"Bundle 'klen/python-mode'

syntax enable

if has('gui_running')
    "set t_Co=256
    set background=dark
    "colorscheme solarized
    "colorscheme molokai
    colorscheme molokai_o
endif

set number
set printoptions=number:y
set encoding=utf-8
set wrap
set shiftwidth=4
set showmode
set warn
filetype plugin on
filetype indent on
set tabstop=4
set expandtab
set stal=1
set path=.,,~/Dropbox/**
set wrapscan
"set guioptions-=T
"set guioptions-=m
set dir=~
set backupdir=~
set autochdir
set spell
autocmd FileType html,css setlocal shiftwidth=2 tabstop=2
autocmd BufRead,BufNewFile *.md set filetype=markdown
nmap t :NERDTreeToggle<CR>
let g:Tex_CompileRule_pdf = 'xelatex -interaction=nonstopmode "$*"'
"let g:molokai_original = 1
let g:syntastic_cpp_compiler_options = 1
set ruler
set cole=0
let g:tex_conceal = ""
let g:pymode_python = 'python3'
"let g:pymode_lint_checkers = ['pyflakes', 'pep8', 'mccabe']
