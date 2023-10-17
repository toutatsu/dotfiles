source $VIMRUNTIME/defaults.vim

" set fileencodings=uft-8

set number

set cursorline
set cursorcolumn

syntax enable

set hlsearch

set incsearch

set wildmenu

set laststatus=2

" Escの2回押しでハイライト消去
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
