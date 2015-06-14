let s:vimfiles = expand(has('win32') ? '$USERPROFILE/vimfiles' : '$HOME/.vim')

" colorscheme
silent! colorscheme sol

" Ignore beep
set visualbell t_vb=

set guioptions&
" Display horizontal scrollbar (limit length of the cursor line)
set guioptions+=b
set guioptions+=h
" Hide toolbar/menubar
set guioptions-=T
set guioptions-=m

" Switch off blinking
set guicursor=a:blinkon0

if has('win32')
  function! ToggleFullscreen()
    if &guioptions =~# 'C'
      set guioptions-=C
      simalt ~r
    else
      set guioptions+=C
      simalt ~x
    endif
  endfunction
  nnoremap <F11> :call ToggleFullscreen()<CR>
endif

" Font
if has('win32')
  set linespace=0
  set renderoptions=type:directx
  if filereadable(expand('$SYSTEMROOT') . '/Fonts/bdfUMplus-outline.ttf')
    set guifont=BDF_UM+_OUTLINE:h10:cDEFAULT
  else
    set guifont=Consolas:h9:cDEFAULT
    set guifontwide=MS_Gothic:h9:cDEFAULT
  endif
elseif has('macunix')
  set linespace=1
  set guifont=Menlo:h12
elseif has('unix')
  if filereadable(expand('$HOME') . '/.fonts/bdfUMplus-outline.ttf')
    set guifont=BDF\ UM+\ OUTLINE\ Medium\ 10
  endif
endif

if has('multi_byte_ime') || has('xim')
  " Change caret color when set IME on
  highlight CursorIM guibg=#af0000
endif

if has('macunix')
  " Fix IME auto off
  set imdisable
endif
