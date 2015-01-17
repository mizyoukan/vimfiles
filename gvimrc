let s:vimfiles = expand(has('win32') ? '$USERPROFILE/vimfiles' : '$HOME/.vim')

" colorscheme
try
  colorscheme sol
catch
endtry

" Ignore beep
set visualbell t_vb=

" Fix corruption of menu text
source $VIMRUNTIME/delmenu.vim
set langmenu=ja_JP.UTF-8
source $VIMRUNTIME/menu.vim

set guioptions&
" Display horizontal scrollbar (limit length of the cursor line)
set guioptions+=b
set guioptions+=h
" Hide toolbar/menubar
set guioptions-=T
set guioptions-=m

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

" Popup menu
if has('win32')
  function! OpenWinExplorer()
    execute '!start explorer /select,' . shellescape(expand('%:p'))
  endfunction
  nmenu PopUp.-Sep- :
  nmenu <silent> PopUp.Open\ Explorer(&E) :call OpenWinExplorer()<CR>
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
elseif has('gui_macvim')
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

if has('gui_macvim')
  " Fix IME auto off
  set imdisable
endif

" Edit/source gvimrc
nnoremap <Space>eg :<C-u>edit $MYGVIMRC<CR>
nnoremap <Space>sg :<C-u>split $MYGVIMRC<CR>
nnoremap <Space>vv :<C-u>source $MYVIMRC \| source $MYGVIMRC<CR>
nnoremap <Space>vg :<C-u>source $MYGVIMRC<CR>

command! -bang MyScouter Scouter<bang> $MYVIMRC $MYGVIMRC

" Load local setting file
if filereadable(s:vimfiles . '/gvimrc_local.vim')
  execute 'source' s:vimfiles . '/gvimrc_local.vim'
endif
