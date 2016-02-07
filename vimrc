execute pathogen#infect()

syntax on
filetype plugin indent on
set nocompatible
set number
set hlsearch

set directory=~/.vim/backup/

" Jump to last position when reopening file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Always start on line 1 of git commits
autocmd FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Indentation
command I2 set ts=2 sw=2 sts=2
command I4 set ts=4 sw=4 sts=4
command I8 set ts=8 sw=8 sts=8
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set nomodeline

" 100 column gutter
highlight ColorColumn ctermbg=darkgrey guibg=#2c2d27
set colorcolumn=101

" Use the X clipboard
set clipboard=unnamedplus

" Alternative to escape
inoremap jj <ESC>

" clang-format shortcuts
noremap jcf :pyf ~/.bin/clang-format.py<CR>
noremap <F4> :pyf ~/.bin/clang-format.py<CR>
inoremap jcf <ESC>:pyf ~/.bin/clang-format.py<CR>i
inoremap <F4> <ESC>:pyf ~/.bin/clang-format.py<CR>i

" Buffer navigation
nnoremap <F11> :prev<CR>
inoremap <F11> <ESC>:prev<CR>i
nnoremap <F12> :next<CR>
inoremap <F12> <ESC>:next<CR>i

" Strip trailing whitespace
nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
inoremap <silent> <F5> <ESC>:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>i

" Allow persistent localvimrc files if answered with uppercase
let g:localvimrc_persistent = 1

" lightline config - fonts at git@github.com:powerline/fonts.git
set laststatus=2
set showtabline=1
set noshowmode
set t_Co=256
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'filename' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightLineFugitive',
      \   'readonly': 'LightLineReadonly',
      \   'modified': 'LightLineModified',
      \   'filename': 'LightLineFilename'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! LightLineModified()
  if &filetype == "help"
    return ""
  elseif &modified
    return "+"
  elseif &modifiable
    return ""
  else
    return ""
  endif
endfunction

function! LightLineReadonly()
  if &readonly
    return ""
  else
    return ""
  endif
endfunction

function! LightLineFugitive()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? ' '._ : ''
  endif
  return ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
       \ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
       \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction
