set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/vundle'

let os = substitute(system('uname'), '\n', '', '')
if os == 'Linux'
    set guifont=WenQuanYi\ Micro\ Hei\ Mono\ Regular\ 14
else
    set guifont=Source\ Code\ Pro:h18
endif

Plugin 'scrooloose/nerdtree'
Plugin 'Yggdroot/indentLine'
Plugin 'tomasr/molokai'
Plugin 'altercation/vim-colors-solarized'
Plugin 'altercation/solarized'
Plugin 'dracula/vim'
Plugin 'ajmwagar/vim-deus'
Plugin 'scrooloose/syntastic'
Plugin 'jalvesaq/colorout'

Plugin 'google/vim-maktaba'
Plugin 'google/vim-codefmt'
Plugin 'google/vim-glaive'

call vundle#end()

call glaive#Install()

syntax enable

if has('gui_running')
    "set t_Co=256
    set background=dark
    colorscheme molokai
else
    set background=dark
    colorscheme molokai
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
set wrapscan
set dir=~
set backupdir=~
set autochdir
set spell
autocmd FileType html,css setlocal shiftwidth=2 tabstop=2
autocmd BufRead,BufNewFile *.md set filetype=markdown
nmap t :NERDTreeToggle<CR>
let g:syntastic_cpp_compiler_options = 1
set ruler
set cole=0
let g:tex_conceal = ""
let g:pymode_python = 'python3'
if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
        \| exe "normal! g'\"" | endif
endif
