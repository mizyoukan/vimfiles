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
  let s:winfontdir = expand('$SYSTEMROOT/Fonts')
  if filereadable(s:winfontdir . '/bdfUMplus-outline.ttf')
    set guifont=BDF_UM+_OUTLINE:h10:cDEFAULT
  else
    set guifont=Consolas:h9:cDEFAULT
    set guifontwide=MS_Gothic:h9:cDEFAULT
  endif
elseif has('gui_macvim')
  set linespace=1
  set guifont=Menlo:h12
endif

if has('multi_byte_ime') || has('xim')
  " Change caret color when set IME on
  highlight CursorIM guibg=#af0000
endif

" Load local setting file
if filereadable(s:vimfiles . '/gvimrc_local.vim')
  execute 'source' s:vimfiles . '/gvimrc_local.vim'
endif
