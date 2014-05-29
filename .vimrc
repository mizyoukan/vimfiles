" Initialize {{{

" GVimは複数起動せずにタブで開く {{{

if has('gui_running') && has('clientserver') && v:servername == 'GVIM1'
  let file = expand('%:p')
  bwipeout
  call remote_send('GVIM', '<ESC>:tabnew ' . file . '<CR>')
  call remote_foreground('GVIM')
  quit
endif

" }}}

" Vi互換をオフ
set nocompatible

" 自分設定用のaugroupをリセット
augroup MyAutoCmd
  autocmd!
augroup END

" ファイルタイプ関連を無効化
filetype plugin indent off

" 設定ファイル配置場所
let s:vimfiles = expand((has('win32') || has('win64')) ? '~/vimfiles' : '~/.vim')

"}}}

" Commands and Functions {{{

" カレントディレクトリを変更
command! -nargs=? -complete=dir -bang CD call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang) "{{{
  if a:directory == ''
    lcd %:p:h
  else
    execute 'lcd' a:directory
  endif
  if a:bang == ''
    pwd
  endif
endfunction "}}}

" カレントバッファを閉じる
function! s:KillCurrentBuffer() "{{{
  let l:bn = bufnr('%')
  bprevious
  execute 'bdelete' l:bn
endfunction "}}}

" Git管理下のディレクトリの場合 /.git/tags を更新
if executable('git') && executable('ctags')
  command! -nargs=0 TUpdate :call s:UpdateCtags()
  function! s:UpdateCtags() "{{{
    lcd %:p:h
    let l:gitdir = substitute(vimproc#system('git rev-parse --git-dir 2> /dev/null'), '\n$', '', 'g')
    if isdirectory(l:gitdir)
      let l:tags = l:gitdir . ((has('win32') || has('win64')) ? '\\' : '/') . 'tags'
      execute vimproc#system('ctags --tag-relative -Raf ' . shellescape(l:tags))
    endif
    lcd -
  endfunction "}}}
endif

" フォールディングで表示する文字列設定
function! s:mbslen(str) "{{{
  let l:char_count = strlen(a:str)
  let l:mchar_count = strlen(substitute(a:str, ".", "x", "g"))
  return l:mchar_count + (l:char_count - l:mchar_count) / 2
endfunction "}}}
function! MyFoldText() "{{{
  let l:left = getline(v:foldstart) . " ..."
  let l:folded_line_count = v:foldend - v:foldstart
  let l:right = "[" . l:folded_line_count . "] "
  let l:nu_col_width = &fdc + &number * &numberwidth
  let l:line_width = winwidth(0) - l:nu_col_width
  let l:space_count = l:line_width - s:mbslen(l:left) - strlen(l:right)
  let l:space = l:space_count > 0 ? repeat(" ", l:space_count) : ""
  return l:left . l:space . l:right
endfunction "}}}

" 存在しリストされているバッファの番号を配列で取得
function! s:BuffersNrListed() "{{{
  let l:nrs = []
  let l:last = bufnr('$')
  let l:i = 0 | while l:i <= l:last | let l:i = l:i + 1
    if buflisted(l:i)
      let l:nrs = add(l:nrs, l:i)
    endif
  endwhile
  return l:nrs
endfunction "}}}

" カレントバッファを別のGVimで開く
if has('clientserver') && has('gui_running') && (has('win32') || has('win64'))
  command! -nargs=0 WinNew call s:OpenWithOtherGVim()
  function! s:OpenWithOtherGVim() "{{{
    if &buftype | echo("Don't work on not normal buffer") | return | endif
    if len(s:BuffersNrListed()) <= 1 | echo("Don't work on only current buffer") | return | endif
    " 重複起動防止処理を避けるため、servernameをGVIM1以外で設定
    let l:serverlist = split(substitute(serverlist(), '\n$', '', 'g'), '\n')
    let l:newservername = 'GVIM2'
    if v:servername == 'GVIM2'
      let l:newservername = len(l:serverlist)==1 ? 'GVIM' : 'GVIM'.(l:serverlist[-1][4:]+1)
    endif
    execute '!start' v:progname shellescape(expand('%')) '--servername' l:newservername
    call s:KillCurrentBuffer()
  endfunction "}}}
endif

" 左移動でこれ以上移動できない場合はfoldingを1段階閉じる
function! s:MoveLeftOrCloseFold() "{{{
  let c = col(".")
  if c == 1
    try
      foldclose
    catch
      echo "折り畳みがありません"
    endtry
  else
    call cursor(line("."), c-1)
  endif
endfunction "}}}

" PowerShellを開く
if executable('powershell')
  command! -nargs=0 PowerShell silent execute ':!start powershell'
endif

"}}}

" Encodings {{{

set encoding=utf-8
set fileencodings=utf-8,cp932,euc-up
if has('win32') || has('win64')
  set termencoding=cp932
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif

"}}}

" Search {{{

" 検索時に大小文字を無視
set ignorecase

" インクリメンタルサーチ
set incsearch

" 検索文字列に大文字が含まれている場合大小文字を区別
set smartcase

"}}}

" Edit {{{

" オートインデント
set autoindent

" OSのクリップボードを使う
set clipboard=unnamed

" 補完ウィンドウの指定
set completeopt=menuone

" タブの代わりにスペースを使う
set expandtab

" 8進数でインクリメント/デクリメントしない
set nrformats=hex

" ファイル切り替え時にファイルを隠す
set hidden

" insert/searchモード開始時にIMEをOFFにする
set iminsert=0 imsearch=0

" マウス操作を有効化
set mouse=a

" 自動インデントに使われる空白の数
set shiftwidth=2

" タブキー押下時に挿入される文字幅（0の場合tabstopの値を使用）
set softtabstop=2

" スマートインデント
set smartindent

" タブ文字の表示幅
set tabstop=2

" コメント行からの改行時のコメント文字列挿入をOFF
augroup AutoCommentOff
  autocmd!
  autocmd BufEnter * setlocal formatoptions&
  autocmd BufEnter * setlocal formatoptions-=r
  autocmd BufEnter * setlocal formatoptions-=o
augroup END

"}}}

" Appearances {{{

" シンタックスハイライト
syntax on

" マルチバイト文字があってもカーソルがずれないようにする
set ambiwidth=double

" ウィンドウのリサイズを抑制
set noequalalways

" フォールディングガイドを非表示
set foldcolumn=0

" フォールディング
set foldmethod=marker

" ブロック単位の移動でfoldingを開かないようにする
set foldopen& foldopen-=block

" フォールディングで表示する文字列設定
set fillchars=vert:\|
set foldtext=MyFoldText()

" ステータスラインを表示
set laststatus=2

" タブ、行末を可視化
set list listchars=tab:^_,trail:_

" 行番号を非表示
set nonumber

" スクロール時の余白確保
set scrolloff=5

" 入力中コマンド表示
set showcmd

" 横分割は右に、縦分割は下に新しいウィンドウを開く
set splitright splitbelow

" ステータスライン
set statusline=%F\ %m%r%h%w%=%{&ff}\ \|\ %{&fenc}\ \|\ %{&ft}\ \|\ %l:%c\ [%p%%]

" 入力中に折り返さない
set textwidth=0

" 補完候補を一覧表示
set wildmenu

" 長い行を折り返し表示しない
set nowrap

" 色数を256色にする
set t_Co=256

"}}}

" File operations {{{

" 読み込んでいるファイルが変更された時自動で読み直す
set autoread

" バックアップファイルを作らない
" set nobackup

" スワップファイルを作らない
" set noswapfile

" ファイルの上書きの前にバックアップを作らない
" set nowritebackup

" バックアップファイル出力先
let s:backupdir = expand(s:vimfiles . '/.backup')
if !isdirectory(s:backupdir)
  call mkdir(s:backupdir)
endif
let &backupdir = s:backupdir

" スワップファイル出力先
let s:swapdir = expand(s:vimfiles . '/.swap')
if !isdirectory(s:swapdir)
  call mkdir(s:swapdir)
endif
let &directory = s:swapdir

" undoファイル出力先
let &undodir = expand(s:vimfiles . '/.undo')

"}}}

" Key mappings {{{

" let mapleader = ','
" noremap \ ,

noremap [option] <Nop>
map <Space> [option]

" 誤爆防止
nnoremap ZZ <Nop>
nnoremap q <Nop>
nnoremap <C-q> <Nop>

" 押し辛い位置のキーの代替
noremap [option]h ^
noremap [option]l $
noremap [option]j %

" .vimrc/.gvimrcを編集
if has('win32') || has('win64')
  nnoremap <silent> [option]ev :<C-u>edit ~\vimfiles\.vimrc<CR>
  nnoremap <silent> [option]eg :<C-u>edit ~\vimfiles\.gvimrc<CR>
else
  nnoremap <silent> [option]ev :<C-u>edit ~/.vim/.vimrc<CR>
  nnoremap <silent> [option]eg :<C-u>edit ~/.vim/.gvimrc<CR>
endif

" .vimrc/.gvimrcを反映
nnoremap <silent> [option]vv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif<CR>
nnoremap <silent> [option]vg :<C-u>if has('gui_running') \| source $MYGVIMRC \| endif<CR>

" 行末までヤンク
nnoremap Y y$

" ESC連打で検索結果ハイライトをクリア
nnoremap <silent><ESC><ESC> :nohlsearch<CR><ESC>

" 画面再描画で検索結果ハイライトをクリア
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" insertモード終了時にIMEをOFF
inoremap <silent><ESC> <ESC>:set iminsert=0<CR>

" コマンド履歴のフィルタリング
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" folding
noremap [option]a za
" 現在のカーソル位置以外閉じる
noremap [option]i zMzv

" 左端で左移動した場合にfoldingを1段階閉じる
" nnoremap <silent> h :<C-u>call <SID>MoveLeftOrCloseFold()<CR>

" wrapをトグル
nnoremap [option]w :set invwrap<CR>

" 表示行移動と論理行移動を交換
nnoremap <Down> gj
nnoremap <Up> gk
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" 検索でvery magicをデフォルトで使う
nnoremap / /\v

" 開いているバッファをカレントディレクトリにする
nnoremap <silent> [option]cd :<C-u>CD<CR>

" バッファリストを前後に移動
nnoremap <C-n> :<C-u>bnext<CR>
nnoremap <C-p> :<C-u>bprev<CR>

" カレントバッファをバッファリストから削除
nnoremap <C-q> :<C-u>call <SID>KillCurrentBuffer()<CR>

" コマンドモードでクリップボードのデータを貼り付け
cnoremap <C-v> <C-r>+

" コマンドモードでEmacsキーバインド
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-g> :<C-u><Esc><CR>

"}}}

" NeoBundle {{{

if executable('git') && !isdirectory(expand(s:vimfiles . '/bundle/neobundle.vim'))
  echo 'install NeoBundle ...'
  call mkdir(iconv(expand(s:vimfiles . '/bundle'), &encoding, &termencoding), 'p')
  call system('git clone https://github.com/Shougo/neobundle.vim ' . shellescape(expand(s:vimfiles . '/bundle/neobundle.vim')))
endif

if has('vim_starting')
  let &runtimepath = &runtimepath . ',' . expand(s:vimfiles . '/bundle/neobundle.vim')
endif
call neobundle#rc(expand(s:vimfiles . '/bundle'))

NeoBundleFetch 'Shougo/neobundle.vim'

"}}}

" Plugins {{{

" vimproc Windows環境ではKaoriya付属のものを使用
if !has('win32') && !has('win64')
  NeoBundle 'Shougo/vimproc', {
    \   'build': {
    \     'mac'  : 'make -f make_mac.mak',
    \     'unix' : 'make -f make_unix.mak'
    \   }
    \ }
endif

" colorscheme
NeoBundle 'jnurmine/Zenburn', {'gui': 0}
NeoBundle 'jonathanfilip/vim-lucius', {'gui': 1}
NeoBundle 'Pychimp/vim-sol', {'gui': 1}
NeoBundle 'vim-scripts/freya', {'gui': 1}
NeoBundle 'vim-scripts/swamplight', {'gui': 1}

NeoBundle 'bling/vim-airline'
NeoBundle 'bling/vim-bufferline'
NeoBundle 'fuenor/qfixhowm'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundleLazy 'junegunn/vim-easy-align'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'kana/vim-textobj-indent', {'depends': 'kana/vim-textobj-user'}
NeoBundle 'kana/vim-textobj-line', {'depends': 'kana/vim-textobj-user'}
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundleLazy 'kmnk/vim-unite-giti', {'depends': 'Shougo/unite.vim'}
NeoBundle 'mhinz/vim-signify'
" NeoBundleLazy 'osyo-manga/unite-qfixhowm', {'depends': 'Shougo/unite.vim'}
NeoBundleLazy 'osyo-manga/unite-quickfix', {'depends': 'Shougo/unite.vim'}
NeoBundleLazy 'scrooloose/syntastic'
NeoBundleLazy 'Shougo/neocomplete.vim', {'autoload': {'insert': 1}}
NeoBundle 'Shougo/neosnippet', {'depends': ['Shougo/neosnippet-snippets', 'honza/vim-snippets']}
NeoBundleLazy 'Shougo/unite.vim', {'autoload': {'commands': 'Unite'}, 'depends': 'Shougo/neomru.vim'}
NeoBundleLazy 'Shougo/unite-outline'
NeoBundleLazy 'Shougo/vimfiler'
NeoBundleLazy 'Shougo/vimshell'
NeoBundleLazy 'thinca/vim-ft-help_fold', {'autoload': {'filetypes': 'help'}}
NeoBundleLazy 'thinca/vim-quickrun', {'autoload': {'commands': 'QuickRun'}}
NeoBundleLazy 'thinca/vim-scouter', {'autoload': {'commands': 'Scouter'}}
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundle 'Yggdroot/indentLine', {'disabled': !has('conceal')}

" Python
NeoBundle 'mizyoukan/vim-virtualenv'

" reStructuredText
NeoBundleLazy 'Rykka/riv.vim', {'autoload': {'filetypes': 'rst'}}

" Markdown
NeoBundleLazy 'kannokanno/previm'

" Scala
NeoBundleLazy 'derekwyatt/vim-scala', {'autoload': {'filetypes': 'scala'}}

" Clojure
" NeoBundleLazy 'thinca/vim-ft-clojure', {'autoload': {'filetypes': 'clojure'}}
NeoBundleLazy 'tpope/vim-fireplace', {'disabled': !has('python'), 'depends': 'tpope/vim-classpath', 'autoload': {'commands': 'Connect'}}

" Javascript
NeoBundleLazy 'jiangmiao/simple-javascript-indenter', {'autoload': {'filetypes': 'javascript'}}
NeoBundleLazy 'jelera/vim-javascript-syntax', {'autoload': {'filetypes': 'javascript'}}

"}}}

" Plugin's options {{{

if neobundle#tap('Zenburn') "{{{
  if !has('gui_running') && !has('win32') && !has('win64')
    try
      colorscheme zenburn
    catch
    endtry
  endif
  call neobundle#untap()
endif "}}}

if neobundle#tap('neocomplete.vim') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neocomplete#data_directory = expand(s:vimfiles . '/.cache/neocomplete')
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_ignore_case = 1
    " let g:neocomplete#enable_insert_char_pre = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#max_list = 20
    let g:neocomplete#force_overwrite_completefunc = 1
    if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'
  endfunction
  call neobundle#untap()
endif "}}}

if neobundle#tap('neosnippet') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neosnippet#enable_snipmate_compatibility = 1
    let g:neosnippet#snippets_directory = expand(s:vimfiles . '/bundle/vim-snippets/snippets')
    let g:neosnippet#data_directory = expand(s:vimfiles . '/.cache/neosnippet')
    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif
  endfunction

  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)

  " snippet操作中にTabキーで次のフィールドに移動
  imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

  call neobundle#untap()
endif "}}}

if neobundle#tap('unite.vim') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    if neobundle#is_installed('vim-unite-giti')
      call neobundle#source('vim-unite-giti')
    endif

    if neobundle#is_installed('unite-quickfix')
      call neobundle#source('unite-quickfix')
    endif

    let g:unite_data_directory = expand(s:vimfiles . '/.cache/unite')
    let g:unite_enable_start_insert = 1
    let g:unite_winheight = 10
    let g:unite_split_rule = 'botright'
    if executable('ag')
      let g:unite_source_grep_command = 'ag'
      let g:unite_source_grep_default_opts = '--nocolor --nogroup'
      let g:unite_source_grep_recursive_opt = ''
      let g:unite_source_grep_max_candidates = 200
    endif

    let g:unite_source_file_mru_ignore_pattern = ''
    let g:unite_source_file_mru_ignore_pattern .= '\~$'
    let g:unite_source_file_mru_ignore_pattern .= '\|\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)'
    if has('win32') || has('win64')
      let g:unite_source_file_mru_ignore_pattern .= '\|AppData/Local/Temp'
      let g:unite_source_file_mru_ignore_pattern .= '\|^//'
  endif
  endfunction

  if !exists('g:unite_source_menu_menus')
    let g:unite_source_menu_menus = {}
  endif

  function! s:unite_menu_input(prompt, exec_command)
    let l:command = [
      \   'let s:capture_input = input("' . a:prompt . '")',
      \   'if s:capture_input !=# ""',
      \     substitute(a:exec_command, '$1', 's:capture_input', 'g'),
      \   'else',
      \     'echo "canceled."',
      \   'endif',
      \   'unlet s:capture_input',
      \ ]
    return join(l:command, '|')
  endfunction

  let g:unite_source_menu_menus.fugitive = {'description': 'A Git wrapper so awesome, it should be illegal'}
  let g:unite_source_menu_menus.fugitive.command_candidates = [
    \   ['[command?]',     s:unite_menu_input('git> ', 'execute "Git!" . $1')],
    \   ['add',            'Gwrite'],
    \   ['blame',          'Gblame'],
    \   ['checkout',       'Gread'],
    \   ['commit',         'Gcommit -v'],
    \   ['commit --amend', 'Gcommit -v --amend'],
    \   ['diff',           'Gdiff'],
    \   ['grep...',        s:unite_menu_input('git grep> ', 'execute("silent Glgrep!" . $1 . " | Unite -auto-preview -auto-resize -winheight=20 location_list")')],
    \   ['mv...',          s:unite_menu_input('git mv dest> ', 'execute "Gmove " . $1')],
    \   ['pull',           'Git! pull'],
    \   ['push',           'Git! push'],
    \   ['remove',         'Gremove'],
    \   ['status',         'Gstatus'],
    \ ]

  if !exists('g:unite_source_alias_aliases')
    let g:unite_source_alias_aliases = {}
  endif

  let g:unite_source_alias_aliases.fugitive = {'source': 'menu'}

  autocmd MyAutoCmd FileType unite call s:unite_my_settings()
  function! s:unite_my_settings()
    nmap <buffer> q <Plug>(unite_exit)
    nmap <buffer> <C-q> <Plug>(unite_exit)
    nmap <buffer> <C-g> <Plug>(unite_exit)
    imap <buffer> <C-q> <Plug>(unite_exit)
    imap <buffer> <C-g><C-g> <Plug>(unite_exit)
    imap <buffer> <C-j> <Plug>(unite_select_next_line)
    imap <buffer> <C-k> <Plug>(unite_select_previous_line)
  endfunction

  nnoremap <silent>[option]u :<C-u>Unite buffer bookmark file file_mru<CR>
  nnoremap <silent>[option]/ :<C-u>Unite line<CR>
  nnoremap <silent>[option]g :<C-u>Glcd \| execute('Unite fugitive:fugitive giti')<CR>

  if executable('lein') "{{{
    if has('win32') || has('win64')
      " For REPL input availability
      call vimshell#util#set_variables({'$LEIN_JVM_OPTS': '-Djline.terminal=jline.UnsupportedTerminal'})
    endif
    let g:unite_source_menu_menus.lein = {
      \   'description': 'Leiningen tasks',
      \   'candidates': [
      \     '?',
      \     'repl', 'deps', 'test', 'clean',
      \     'ring server', 'ring server-headless',
      \     'cljsbuild auto', 'cljsbuild auto dev', 'cljsbuild once', 'cljsbuild clean',
      \   ],
      \ }
    function! g:unite_source_menu_menus.lein.map(key, value)
      if a:value ==# '?'
        return {
          \   'word': '[command?]',
          \   'kind': 'command',
          \   'action__command': s:unite_menu_input(
          \     'lein task> ',
          \     'execute ''VimShellInteractive --split="split | resize 10" lein '' . $1'),
          \ }
      endif
      return {
        \   'word': a:value,
        \   'kind': 'command',
        \   'action__command': 'VimShellInteractive --split="split | resize 10" lein ' . a:value,
        \ }
    endfunction
    autocmd MyAutoCmd FileType clojure nnoremap <buffer><silent>[option]m :<C-u>Unite menu:lein<CR>
  endif "}}}

  call neobundle#untap()
endif "}}}

if neobundle#tap('unite-qfixhowm') "{{{
  call neobundle#config({'depends': ['Shougo/unite.vim', 'fuenor/qfixhowm']})

  function! neobundle#tapped.hooks.on_source(bundle)
    " 更新日時で降順ソート
    call unite#custom#source('qfixhowm', 'filters', ['sorter_qfixhowm_updatetime', 'sorter_reverse'])
    call unite#custom#source('qfixhowm:nocache', 'filters', ['sorter_qfixhowm_updatetime', 'sorter_reverse'])
  endfunction

  " nnoremap <silent>[option]mm :<C-u>Unite qfixhowm/new qfixhowm -hide-source-names<CR>
  " nnoremap <silent>[option]ma :<C-u>Unite qfixhowm/new qfixhowm:nocache -hide-source-names<CR>

  call neobundle#untap()
endif "}}}

if neobundle#tap('unite-outline') "{{{
  call neobundle#config({'depends': 'Shougo/unite.vim'})

  nnoremap <silent>[option]o :<C-u>Unite outline -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>

  call neobundle#untap()
endif "}}}

if neobundle#tap('vimfiler') "{{{
  call neobundle#config({
    \   'depends': 'Shougo/unite.vim',
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimFiler', 'complete': 'customhist,vimfiler#complete'},
    \       'VimFilerBufferDir', 'Edit', 'Read', 'Source', 'Write'
    \     ],
    \     'mappings': '<Plug>(vimfiler_',
    \     'explorer': 1
    \   }
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:vimfiler_data_directory = expand(s:vimfiles . '/.cache/vimfiler')
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_safe_mode_by_default = 0
    let g:vimfiler_tree_leaf_icon = ' '
    let g:vimfiler_tree_indentation = 2
    if has('mac')
      call vimfiler#set_execute_file('mp3,wav', 'afplay')
    elseif has('unix')
      call vimfiler#set_execute_file('wav', 'aplay')
      call vimfiler#set_execute_file('mp3', 'mpg321')
      call vimfiler#set_execute_file('ogg', 'ogg123')
    endif
  endfunction

  " 現在開いているバッファをIDE風に開く
  nnoremap <silent>[option]f :<C-u>VimFilerBufferDir -buffer-name=explorer -explorer -split -simple -toggle -winwidth=35 -no-quit<CR>

  call neobundle#untap()
endif "}}}

if neobundle#tap('vimshell') "{{{
  call neobundle#config({
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimShell', 'complete': 'customlist,vimshell#complete'},
    \       'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop', 'VimShellTab'
    \     ],
    \     'mappings': '<Plug>(vimshell_'
    \   }
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:vimshell_temporary_directory = expand(s:vimfiles . '/.cache/vimshell')
    " 毎回カレントディレクトリを表示
    let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
    let g:vimshell_prompt = ((has('win32') || has('win64')) ? $USERNAME : $USER) . '% '
    " 画面を分割するときに用いるExコマンド
    let g:vimshell_split_command = 'split'
    if has('win32') || has('win64')
      autocmd MyAutoCmd FileType vimshell setlocal fileencoding=sjis
    endif
  endfunction

  nnoremap <silent>[option]s :<C-u>VimShell -split<CR>

  call neobundle#untap()
endif "}}}

if neobundle#tap('neomru.vim') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neomru#file_mru_path = expand(s:vimfiles . '/.cache/neomru/file')
    let g:neomru#directory_mru_path = expand(s:vimfiles . '/.cache/neomru/directory')
  endfunction
endif "}}}

if neobundle#tap('ctrlp.vim') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:ctrlp_clear_cache_on_exit = 0
    let g:ctrlp_use_migemo = 1
    " C-hでBackspace (カーソル移動からC-hを除外)
    let g:ctrlp_prompt_mappings = {
      \   'PrtBS()': ['<bs>', '<C-h>', '<C-]>'],
      \   'PrtCurLeft()': ['<left>', '<C-^>']
      \ }
  endfunction
  let g:ctrlp_cache_dir = expand(s:vimfiles . '/.cache/ctrlp')
  let g:ctrlp_map = '<C-@>'
  let g:ctrlp_custom_ignore = {
    \   'file': '\v\.(dll|exe|jar|so)$',
    \   'dir': '\v[\\/](out|repl|target)$'
    \ }
  call neobundle#untap()
endif "}}}

if neobundle#tap('rainbow_parentheses.vim') "{{{
  autocmd MyAutoCmd VimEnter * RainbowParenthesesToggle
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadRound
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadSquare
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadBraces
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-airline') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    if neobundle#is_installed('vim-bufferline')
      call neobundle#source('vim-bufferline')
    endif

    " モード名表示を1文字にする
    let g:airline_mode_map = {
      \   '__' : '-',
      \   'n'  : 'N',
      \   'i'  : 'I',
      \   'R'  : 'R',
      \   'c'  : 'C',
      \   'v'  : 'V',
      \   'V'  : 'V',
      \   '' : 'V',
      \   's'  : 'S',
      \   'S'  : 'S',
      \   '' : 'S',
      \ }
    " statusline設定を抑制
    let g:unite_force_overwrite_statusline = 0
    let g:vimfiler_force_overwrite_statusline = 0
  endfunction
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-bufferline') "{{{
  " quickrun用
  let g:bufferline_echo = 0
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-quickrun') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    if !has('g:quickrun_config')
      let g:quickrun_config = {}
    endif

    let g:quickrun_config._ = {
      \   'outputter': 'multi:buffer:quickfix',
      \   'outputter/buffer/split': 'botright 10sp',
      \   'outputter/buffer/running_mark': '(」・ω・)」うー！(/・ω・)/にゃー！',
      \   'outputter/buffer/close_on_empty': 1,
      \   'runner': 'vimproc',
      \   'runner/vimproc/updatetime': 50,
      \   'runner/vimproc/sleep': 0,
      \ }

    if has('win32') || has('win64')
      let s:hook = {
        \   'name': 'virtualenv',
        \   'kind': 'hook',
        \   'config': {'enable': 0},
        \ }

      function! s:hook.init(session)
        if !self.config.enable
          return
        endif
        if !exists('g:virtualenv_name')
          return
        endif
        let python_path = g:virtualenv_directory . '\' . g:virtualenv_name . '\Scripts\python.exe'
        let a:session.config.command = python_path
      endfunction

      call quickrun#module#register(s:hook, 1)
      unlet s:hook

      let g:quickrun_config.python = {
        \   'type': 'python',
        \   'hook/virtualenv/enable': 1,
        \ }
    endif

    if executable('CScript')
      let g:quickrun_config.vb = {
        \   'command': 'CScript',
        \   'exec': '%c //Nologo //E:VBScript %s',
        \   'hook/output_encode/encoding': 'cp932',
        \   'outputter/quickfix/errorformat': '%f(%l\\,\ %c)\ Microsoft\ VBScript\ %m',
        \ }

      let g:quickrun_config.javascript = {
        \   'command': 'CScript',
        \   'exec': '%c //Nologo //E:JScript %s',
        \   'hook/output_encode/encoding': 'cp932',
        \   'outputter/quickfix/errorformat': '%f(%l\\,\ %c)\ Microsoft\ JScript\ %m',
        \ }
    endif

    autocmd MyAutoCmd FileType quickrun nnoremap <buffer> q :quit<CR>
  endfunction

  nnoremap <silent>[option]q :<C-u>QuickRun<CR>

  call neobundle#untap()
endif "}}}

if neobundle#tap('syntastic') "{{{
  call neobundle#config({
    \   'autoload': {'filetypes': ['go', 'python']}
    \ })
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:syntastic_mode_map = {
      \   'mode': 'active',
      \   'active_filetypes': ['go', 'python'],
      \   'passive_filetypes': []
      \ }
    let g:syntastic_python_checkers = ['flake8']
    if executable('golint')
      let g:syntastic_go_checkers = ['go', 'golint']
    endif
  endfunction
  call neobundle#untap()
endif "}}}

if neobundle#tap('qfixhowm') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:qfixmemo_dir = expand('~/memo')
    let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d-%H%M%S'
    let g:qfixmemo_filetype = ''
    let g:qfixmemo_title = '#'
    let g:qfixmemo_timeformat = 'last update: %Y-%m-%d %H:%M'
    let g:qfixmemo_use_updatetime = 1
    let g:qfixmemo_timeformat_regxp = '^last update: \d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}'
    let g:qfixmemo_timestamp_regxp  = g:qfixmemo_timeformat_regxp
    if (has('win32') || has('win64')) && !executable('grep')
      let mygreparg = 'findstr'
      let myjpgrepprg = 'agrep.vim'
    endif
    let g:qfixmemo_template = [
      \   substitute('%TITLE% [] <_1_>', '_', '`', 'g'),
      \   '%DATE%',
      \   '',
      \   substitute('<_0_>', '_', '`', 'g')
      \ ]
    let g:qfixmemo_template_keycmd = '$F[a'
    let g:qfixmemo_use_howm_schedule = 0
    let g:QFixMRU_Filename = expand(s:vimfiles . '/.cache/qfixmru')
    let g:QFixHowm_HolidayFile = expand(s:vimfiles . '/bundle/qfixhowm/misc/holiday/Sche-Hd-0000-00-00-000000.utf8')
  endfunction
  let g:QFixHowm_Convert = 0
  let g:disable_QFixWin = 1
  let g:qfixmemo_mapleader = 'm'
  let g:qfixmemo_ext = 'md'
  noremap mt :<C-u>call howm_schedule#QFixHowmSchedule('todo', expand('~/memo'), 'utf-8')<CR>
  call neobundle#untap()
endif "}}}

if neobundle#tap('auto-pairs') "{{{
  let g:AutoPairsMapSpace = 0
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-ft-clojure') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:clojure#indent#special = '\%(defroutes\)$'
  endfunction
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-classpath') "{{{
  let g:classpath_cache = expand(s:vimfiles . '/.cache/classpath')
  call neobundle#untap()
endif "}}}

if neobundle#tap('riv.vim') "{{{
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:riv_global_leader = '<C-e>'
    " ファイルリンクスタイルをSphinxスタイルに設定
    let g:riv_file_link_style = 2
    " 2行以上の空行をフォールディング
    let g:riv_fold_blank = 1
    " フォールディングをセクションのみとする
    let g:riv_fold_level = 1
  endfunction
  call neobundle#untap()
endif "}}}

if neobundle#tap('previm') "{{{
  call neobundle#config({
    \   'depends': 'tyru/open-browser.vim',
    \   'autoload': {'commands': 'PrevimOpen'}
    \ })
  autocmd MyAutoCmd FileType markdown nnoremap <silent> <buffer> [option]p :<C-u>PrevimOpen<CR>
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-easy-align') "{{{
  call neobundle#config({
    \   'autoload': {
    \     'commands': ['EasyAlign', 'LiveEasyAlign'],
    \     'mappings': '<Plug>(EasyAlign)'
    \   }
    \ })
  vmap <Enter> <Plug>(EasyAlign)
  call neobundle#untap()
endif "}}}

if neobundle#tap('vim-operator-user') "{{{
  " JSONデータを整形
  if executable('jq')
    function! Op_json_format(motion_wise)
      execute "'[,']" "!jq ."
    endfunction
    call operator#user#define('json-format', 'Op_json_format')
    map X <Plug>(operator-json-format)
  endif

  call neobundle#untap()
endif "}}}

"}}}

" Filetypes {{{

" VimScript
let g:vim_indent_cont = 2

" QuickFix
autocmd MyAutoCmd FileType qf nnoremap <buffer> p <CR>zz<C-w>p
autocmd MyAutoCmd FileType qf nnoremap <buffer> q :quit<CR>

" Diff
autocmd MyAutoCmd FileType diff setlocal foldlevel=99

" Help
autocmd MyAutoCmd FileType help setlocal nolist
autocmd MyAutoCmd FileType help nnoremap <buffer> q :quit<CR>

" Git
autocmd MyAutoCmd FileType git setlocal foldlevel=99
autocmd MyAutoCmd FileType gitcommit setlocal foldlevel=99

" Python
autocmd MyAutoCmd FileType python setlocal shiftwidth=4 softtabstop=4 tabstop=8
autocmd MyAutoCmd FileType python setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd MyAutoCmd FileType python inoremap <buffer> # X#

" Golang
autocmd MyAutoCmd FileType go setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd MyAutoCmd FileType go setlocal foldlevel=99 foldmethod=syntax foldnestmax=1
autocmd MyAutoCmd FileType go setlocal list listchars=tab:\ \ ,trail:_
if $GOPATH != ''
  autocmd MyAutoCmd FileType go autocmd BufWritePre <buffer> Fmt

  if executable('gocode')
    execute 'set runtimepath+=' . globpath($GOPATH, 'src/github.com/nsf/gocode/vim')
    if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
    endif
    let g:neocomplete#sources#omni#input_patterns.go = '[^. \t[:digit:]]\.\w*'
  endif

  if executable('golint')
    execute 'set runtimepath+=' . globpath($GOPATH, 'src/github.com/golang/lint/misc/vim')
  endif
endif

" Clojure
let g:clojure_align_multiline_strings = 1

" Markdown
autocmd MyAutoCmd BufNewFile,BufRead *.{md,mkd,markdown} setlocal filetype=markdown
autocmd MyAutoCmd FileType markdown setlocal shiftwidth=4 softtabstop=4 tabstop=4
autocmd MyAutoCmd FileType markdown setlocal foldlevel=99 foldlevelstart=99
let g:markdown_fenced_languages = [
  \   'diff',
  \   'dosbatch',
  \   'ini=dosini',
  \   'javascript',
  \   'json=javascript',
  \   'properties=jproperties',
  \   'sh',
  \   'sql',
  \ ]

" reStructuredText
autocmd MyAutoCmd FileType rst setlocal shiftwidth=3 nosmartindent smarttab softtabstop=3 tabstop=3 wrap

" JScript
autocmd MyAutoCmd BufNewFile,BufRead *.js.bat setlocal filetype=javascript fileencoding=sjis
let s:jsbat_template = [
  \   '@if (0)==(0) echo off',
  \   'pushd %~dp0',
  \   'CScript //Nologo //E:JScript "%~f0" %*',
  \   'popd',
  \   'goto :EOF',
  \   '@end',
  \   '',
  \   '/* vim: set ft=javascript : */',
  \ ]
autocmd MyAutoCmd BufNewFile *.js.bat call append(0, s:jsbat_template)|normal Gdd{

" VBScript
autocmd MyAutoCmd FileType vb setlocal shiftwidth=4 softtabstop=4 tabstop=4

"}}}

" Finalize {{{

" ローカル設定をvimrc_local.vimから読み込む
if filereadable(s:vimfiles . '/vimrc_local.vim')
  execute 'source' s:vimfiles . '/vimrc_local.vim'
endif

" ファイルタイプ関連を有効化
filetype plugin indent on

NeoBundleCheck

"}}}
