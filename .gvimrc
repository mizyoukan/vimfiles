" 設定ファイル配置場所
let s:vimfiles = expand(has('win32') ? '$USERPROFILE/vimfiles' : '$HOME/.vim')

" colorscheme
try
  colorscheme sol
  highlight Comment guifg=#a0a0a0
  highlight Folded guifg=#8d8d8d
catch
endtry

" ビープ音を消す
set visualbell t_vb=

set guioptions&
" Display horizontal scrollbar (limit length of the cursor line)
set guioptions+=b
set guioptions+=h
" Hide toolbar/menubar
set guioptions-=T
set guioptions-=m

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
  " IMEがONになったらキャレットの色を変更
  highlight CursorIM guibg=#af0000
endif

" ローカル設定をgvimrc_local.vimから読み込む
if filereadable(s:vimfiles . '/gvimrc_local.vim')
  execute 'source' s:vimfiles . '/gvimrc_local.vim'
endif
