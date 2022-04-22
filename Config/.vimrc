let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Programming plugins
Plug 'rust-lang/rust.vim'

" Config files
Plug 'fladson/vim-kitty'

" File explorer
Plug 'vifm/vifm.vim'

" Highlight colors
Plug 'ap/vim-css-color'

" Cool things
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'frazrepo/vim-rainbow'
Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'mcchrish/nnn.vim'

call plug#end()

" Activate vim-rainbow
let g:rainbow_active = 1

set laststatus=2

" Vim only
set nocompatible

" Show line number
set number

" Automatic wrapping
set wrap

" Encoding
set encoding=utf-8
