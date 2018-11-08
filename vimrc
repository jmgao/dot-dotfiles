execute pathogen#infect()

syntax on
filetype plugin indent on
set nocompatible
set number
set hlsearch
set backspace=indent,eol,start

set directory=~/.vim/backup//

" Jump to last position when reopening file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Always start on line 1 of git commits
autocmd FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Indentation
command I2 set ts=2 sw=2 sts=2
command I4 set ts=4 sw=4 sts=4
command I8 set ts=8 sw=8 sts=8

" Blueprint style is 4 space indentation.
autocmd BufNewFile,BufRead *.bp I4

I2

set expandtab
set nomodeline

" 100 column gutter
highlight ColorColumn ctermbg=darkgrey guibg=#2c2d27
set colorcolumn=101

" Black on yellow highlight
highlight Search ctermfg=0 ctermbg=11
highlight SpellBad cterm=reverse ctermfg=1 ctermbg=16

" Speed up vim-gitgutter updates
set updatetime=1000

" Use the X clipboard
set clipboard=unnamedplus

" Don't clear the clipboard on exit.
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Alternative to escape
inoremap jj <ESC>

" Code formatter keybinds/settings
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

noremap <F3> :YcmCompleter FixIt<CR>:ccl<CR>
inoremap <F3> <ESC>:YcmCompleter FixIt<CR>:ccl<CR>i

autocmd BufWritePost,BufNewFile,BufRead * call AutoformatBind()

" Strip trailing whitespace on save
command StripTrailingWhitespace %s/\s\+$//e
autocmd BufWritePre * %s/\s\+$//e

" Fugitive keybinds
noremap jgb :Gblame<CR>

" Buffer navigation
nnoremap <F11> :prev<CR>
inoremap <F11> <ESC>:prev<CR>i
nnoremap <F12> :next<CR>
inoremap <F12> <ESC>:next<CR>i

" Ctrl-A/Ctrl-E
map <C-A> ^
map! <C-A> <ESC>I
map <C-E> $
map! <C-E> <ESC>A

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
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightLineFugitive',
      \   'filename': 'LightLineFilename',
      \   'fileformat': 'LightLineFileformat',
      \   'filetype': 'LightLineFiletype',
      \   'fileencoding': 'LightLineFileencoding',
      \   'mode': 'LightLineMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! LightLineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help' && &readonly ? '' : ''
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' && has_key(g:lightline, 'ctrlp_item') ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ' '  " edit here for cool mark
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP' && has_key(g:lightline, 'ctrlp_item')
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

let g:autocwd_patternwd_pairs = [
  \['*', '*REPO*'],
\]

nnoremap gd :YcmCompleter GoTo<CR>

" 2sp for lyfe
let g:rust_recommended_style = 0

let g:ycm_rust_src_path = $RUST_SRC_PATH

set hidden

let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_auto_trigger = 1
let g:ycm_always_populate_location_list = 1
let g:ycm_min_num_of_chars_for_completion = 4
let g:ycm_complete_in_comments = 0
let g:ycm_complete_in_strings = 0

noremap <F5> :YcmForceCompileAndDiagnostics<CR><CR>
inoremap <F5> <ESC>:YcmForceCompileAndDiagnostics<CR><CR>i

let g:linuxsty_patterns = [ "/linux/", "/kernel/" ]

" Ctrl-A/Ctrl-E
map <C-A> ^
map! <C-A> <ESC>I
map <C-E> $
map! <C-E> <ESC>A
