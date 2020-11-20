syntax on
filetype plugin indent on

set number
set hlsearch
set backspace=indent,eol,start
set nomodeline

" Use the X clipboard
set clipboard=unnamedplus

" Don't clear the clipboard on exit.
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Ctrl-A/Ctrl-E
map <C-A> ^
map! <C-A> <ESC>I
map <C-E> $
map! <C-E> <ESC>A

" Jump to last position when reopening file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Always start on line 1 of git commits
autocmd FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Indentation
command I2 set ts=2 sw=2 sts=2
command I4 set ts=4 sw=4 sts=4
command I8 set ts=8 sw=8 sts=8
set expandtab
I2

" Blueprint style is 4 space indentation.
autocmd BufNewFile,BufRead *.bp I4

" Strip trailing whitespace on save
command StripTrailingWhitespace %s/\s\+$//e
autocmd BufWritePre * %s/\s\+$//e

" 100 column gutter
highlight ColorColumn ctermbg=darkgrey guibg=#2c2d27
set colorcolumn=101

" Black on yellow highlight
highlight Search ctermfg=0 ctermbg=11
highlight SpellBad cterm=reverse ctermfg=1 ctermbg=16

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin(stdpath('data') . '/plugged')

Plug 'yssl/AutoCWD.vim'
let g:autocwd_patternwd_pairs = [
  \['*', '*REPO*'],
\]

Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

Plug 'airblade/vim-gitgutter'
set updatetime=100

Plug 'embear/vim-localvimrc'
let g:localvimrc_persistent = 1

Plug 'itchyny/lightline.vim'
source ~/.config/nvim/lightline.vim

Plug 'Chiel92/vim-autoformat'
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
function AutoformatBind()
  if &ft =~ 'c$\|cpp$'
    noremap jcf :pyxf ~/.bin/clang-format.py<CR>
    noremap <F4> :pyxf ~/.bin/clang-format.py<CR>
    inoremap jcf <ESC>:pyxf ~/.bin/clang-format.py<CR>i
    inoremap <F4> <ESC>:pyxf ~/.bin/clang-format.py<CR>i
  elseif &ft =~ 'rust$'
    noremap jcf :RustFmt<CR>
    noremap <F4> :RustFmt<CR>
  else
    noremap jcf :Autoformat<CR>
    noremap <F4> :Autoformat<CR>
    inoremap jcf <ESC>:Autoformat<CR>i
    inoremap <F4> <ESC>:Autoformat<CR>i
  endif
endfunction
autocmd BufWritePost,BufNewFile,BufRead * call AutoformatBind()

Plug 'rust-lang/rust.vim'
let g:rust_recommended_style = 0

Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': 'bash install.sh',
  \ }
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1
inoremap <expr><C-Space> deoplete#mappings#manual_complete()

set hidden
let g:LanguageClient_serverCommands = {
  \ 'rust': ['rustup', 'run', 'stable', 'rls'],
  \ }

Plug 'sirtaj/vim-openscad'
call plug#end()

let g:omni_sql_no_default_maps = 1
