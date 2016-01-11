" colorscheme
augroup colorscheme_sol
  autocmd!
  autocmd ColorScheme sol highlight Comment guifg=#a0a0a0
  autocmd ColorScheme sol highlight Folded guifg=#8d8d8d
  autocmd ColorScheme sol highlight IncSearch guibg=#9999ff
  autocmd ColorScheme sol highlight MatchParen guibg=#8d8d8d
  autocmd ColorScheme sol highlight Search guibg=#ccccff
  autocmd ColorScheme sol highlight SpecialKey guifg=#b592e8
  autocmd ColorScheme sol highlight StatusLine guibg=#404040 guifg=#dfdfdf
  autocmd ColorScheme sol highlight StatusLineNC guibg=#8d8d8d guifg=#dfdfdf
  autocmd ColorScheme sol highlight CursorIM guibg=#af0000
augroup END
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
  function! s:toggle_fullscreen()
    if &guioptions =~# 'C'
      set guioptions-=C
      simalt ~r
    else
      set guioptions+=C
      simalt ~x
    endif
  endfunction
  nnoremap <F11> :<C-U>call <SID>toggle_fullscreen()<CR>
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

if has('macunix')
  " IME auto off
  set imdisable
endif
