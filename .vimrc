syntax on

" https://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim/21323445#21323445
" Use filetype detection and file-based automatic indenting.
filetype plugin indent on
" Use actual tab chars in Makefiles.
autocmd FileType make set noexpandtab

set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number
set smartcase
set hlsearch
set incsearch
let mapleader = "\<Space>"

" Toggle numbering settings
nmap <F3> :set nu! <CR>
nmap <Leader><F3> :set rnu! <CR>

" Same as above, but for insert mode
imap <F3> <ESC> :set nu! <CR>i
imap <F4> <ESC> :set rnu! <CR>i

" netrw: toggle hiding of files
nmap <F5> gh
" netrw: toggle the banner
nmap <F6> I

let g:netrw_preview = 1 " open splits to the right instead of the left
let g:netrw_winsize = 30
" Note: Might wanna rm -r ~/.vim/view once in a while
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview
