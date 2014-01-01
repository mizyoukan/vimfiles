" 設定ファイル配置場所
let s:vimfiles = expand((has('win32') || has('win64')) ? '~/vimfiles' : '~/.vim')

" colorscheme
try
  colorscheme sol
  highlight Comment guifg=#a0a0a0
  highlight Folded guifg=#8d8d8d
catch
endtry

" ウィンドウサイズ
set columns=100 lines=30

" ビープ音を消す
set visualbell t_vb=

" GUI options {{{

set guioptions&

" ツールバー非表示
if &guioptions =~# 'T'
  set guioptions-=T
endif

" メニューバー非表示
if &guioptions =~# 'm'
  set guioptions-=m
endif

" 水平スクロールバー表示
if &guioptions !~# 'b'
  set guioptions+=b
endif

"}}}

" Font
set linespace=1
if has('win32') || has('win64')
  set guifont=Consolas:h9:cDEFAULT
  set guifontwide=MS_Gothic:h10.5:cDEFAULT
elseif has('gui_macvim')
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
