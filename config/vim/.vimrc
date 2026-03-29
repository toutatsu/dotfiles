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

" Indent
set expandtab     " タブをスペースに展開
set tabstop=4     " タブ幅
set shiftwidth=4  " インデント幅

" Clipboard
set clipboard=unnamedplus  " システムクリップボードと連携

" Escの2回押しでハイライト消去
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>

" ノーマルモードに戻る
inoremap ;j <Esc>
vnoremap ;j <Esc>
cnoremap ;j <C-C>
