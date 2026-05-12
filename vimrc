set nocompatible
scriptencoding utf-8
set encoding=utf-8

let s:plug_site = has('nvim') ? stdpath('data') . '/site' : expand('~/.vim')
let s:plug_file = s:plug_site . '/autoload/plug.vim'
let s:plugged_dir = has('nvim') ? stdpath('data') . '/plugged' : expand('~/.vim/plugged')

if empty(glob(s:plug_file))
  if executable('curl')
    silent execute '!curl -fLo ' . shellescape(s:plug_file) . ' --create-dirs ' .
          \ shellescape('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  else
    echoerr 'vim-plug is missing and curl is not available to install it.'
  endif
endif

if filereadable(s:plug_file)
  call plug#begin(s:plugged_dir)

  Plug 'preservim/nerdtree'
  Plug 'Yggdroot/indentLine'
  Plug 'nanotech/jellybeans.vim'
  Plug 'dracula/vim', { 'as': 'dracula' }
  Plug 'ajmwagar/vim-deus'
  Plug 'jalvesaq/colorout'

  Plug 'dense-analysis/ale'

  Plug 'google/vim-maktaba'
  Plug 'google/vim-codefmt'
  Plug 'google/vim-glaive'

  call plug#end()
endif

silent! call glaive#Install()

if has('gui_running')
  if has('unix') && !has('macunix')
    set guifont=WenQuanYi\ Micro\ Hei\ Mono\ Regular\ 14
  else
    set guifont=Source\ Code\ Pro:h18
  endif
endif

syntax enable
filetype plugin indent on

let g:rehash256 = 1
set background=dark
silent! colorscheme jellybeans

set number
set printoptions=number:y
set wrap
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set showmode
set warn
set ruler
set showtabline=1
set wrapscan
set conceallevel=0
set noautochdir

let s:state_dir = expand('~/.vim')
call mkdir(s:state_dir . '/backup', 'p')
call mkdir(s:state_dir . '/swap', 'p')
call mkdir(s:state_dir . '/undo', 'p')
execute 'set backupdir^=' . fnameescape(s:state_dir . '/backup//')
execute 'set directory^=' . fnameescape(s:state_dir . '/swap//')
if has('persistent_undo')
  set undofile
  execute 'set undodir^=' . fnameescape(s:state_dir . '/undo//')
endif

let g:tex_conceal = ''
let g:ale_lint_on_text_changed = 'normal'
let g:ale_fix_on_save = 0

nnoremap <silent> <Leader>n :NERDTreeToggle<CR>

augroup user_vimrc
  autocmd!
  autocmd FileType html,css setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
  autocmd BufRead,BufNewFile *.md setfiletype markdown
  autocmd FileType gitcommit,markdown,text setlocal spell
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
augroup END
