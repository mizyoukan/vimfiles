" Initialize {{{

" Vi互換をオフ
set nocompatible

let s:vimfiles = expand((has('win32') || has('win64')) ? '~/vimfiles' : '~/.vim')

" Load local setting file first
if filereadable(s:vimfiles . '/vimrc_local_first.vim')
  execute 'source' s:vimfiles . '/vimrc_local_first.vim'
endif

" 多重起動しない
let g:SingleWindowBootEnable = get(g:, 'SingleWindowBootEnable', 1)
if g:SingleWindowBootEnable == 1
  if has('gui_running') && has('clientserver') && v:servername == 'GVIM1'
    let file = expand('%:p')
    bwipeout
    call remote_send('GVIM', '<ESC>:tabnew ' . file . '<CR>')
    call remote_foreground('GVIM')
    quit
  endif
endif

" Reset my autocmd group
augroup MyAutoCmd
  autocmd!
augroup END

" ファイルタイプ関連を無効化
filetype plugin indent off

"}}}

" Commands and Functions {{{

" Delete current buffer without closing window
command! -nargs=0 -bang KillCurrentBuffer call <SID>KillCurrentBuffer('<bang>')
function! s:KillCurrentBuffer(bang) "{{{
  let l:bn = bufnr('%')
  bprevious
  try
    execute 'bdelete'.a:bang l:bn
  catch /E89:/
    execute 'buffer' l:bn
    echoerr v:exception
  endtry
endfunction "}}}

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

" Open PowerShell based on current buffer
if executable('powershell')
  command! -nargs=0 PowerShell silent execute
    \ ':!start powershell -NoLogo -NoExit -Command Set-Location ' .
    \ shellescape(expand('%:p:h'))
endif

" Toggle golang impl/test file
function! GolangToggleFile(editCmd)
  let currFile = expand("%")
  if match(currFile, "_test\.go$") >= 0
    let fileToOpen = split(currFile, "_test\.go$")[0] . ".go"
  else
    let fileToOpen = split(currFile, "\.go$")[0] . "_test.go"
  endif
  execute ":" . a:editCmd . " " . fileToOpen
endfunction

" Source all unsourced plugins
command! -nargs=0 MyNeoBundleSourceAll silent call <SID>MyNeoBundleSourceAll()
function! s:MyNeoBundleSourceAll()
  for bundle in neobundle#config#get_neobundles()
    if !neobundle#is_sourced(bundle.name)
      call neobundle#config#source(bundle.name)
    endif
  endfor
endfunction

" Set IME off when insert leave
if executable('fcitx-remote')
  set ttimeoutlen=150
  autocmd MyAutoCmd InsertLeave * call system('fcitx-remote -c')
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

" Highlight all matches
set hlsearch

" tags {{{
set tags&
let s:tags = expand(s:vimfiles . '/.tags')
if isdirectory(s:tags)
  let &tags = &tags . ',' . expand(s:tags . '/*')
endif
unlet s:tags
"}}}

"}}}

" Edit {{{

" オートインデント
set autoindent

" OSのクリップボードを使う
set clipboard=unnamed,unnamedplus

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

" Display window title
set title

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

" 押し辛い位置のキーの代替
noremap [option]h ^
noremap [option]l $
noremap [option]j %

" .vimrc/.gvimrcを編集
if has('win32') || has('win64')
  nnoremap <silent> [option]ev :<C-u>edit ~\vimfiles\.vimrc<CR>
  nnoremap <silent> [option]eg :<C-u>edit ~\vimfiles\.gvimrc<CR>
  nnoremap <silent> [option]ef :<C-u>edit ~\vimfiles\vimrc_local_first.vim<CR>
  nnoremap <silent> [option]el :<C-u>edit ~\vimfiles\vimrc_local_last.vim<CR>
else
  nnoremap <silent> [option]ev :<C-u>edit ~/.vim/.vimrc<CR>
  nnoremap <silent> [option]eg :<C-u>edit ~/.vim/.gvimrc<CR>
  nnoremap <silent> [option]ef :<C-u>edit ~/.vim/vimrc_local_first.vim<CR>
  nnoremap <silent> [option]el :<C-u>edit ~/.vim/vimrc_local_last.vim<CR>
endif

" .vimrc/.gvimrcを反映
nnoremap <silent> [option]vv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif<CR>
nnoremap <silent> [option]vg :<C-u>if has('gui_running') \| source $MYGVIMRC \| endif<CR>
if has('win32') || has('win64')
  nnoremap [option]vl :<C-u>source ~\vimfiles\vimrc_local_last.vim<CR>
else
  nnoremap [option]vl :<C-u>source ~/.vim/vimrc_local_last.vim<CR>
endif

" 行末までヤンク
nnoremap Y y$

" ESC連打で検索結果ハイライトをクリア
nnoremap <silent><ESC><ESC> :nohlsearch<CR><ESC>

" 画面再描画で検索結果ハイライトをクリア
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" insertモード終了時にIMEをOFF
autocmd MyAutoCmd InsertLeave * setlocal iminsert=0 imsearch=0

" コマンド履歴のフィルタリング
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" folding
noremap [option]a za
" 現在のカーソル位置以外閉じる
noremap [option]i zMzv

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

" Change local cd to current buffer's dir
nnoremap <silent> [option]cd :<C-u>lcd %:p:h<CR>:pwd<CR>

" バッファリストを前後に移動
nnoremap <C-n> :<C-u>bnext<CR>
nnoremap <C-p> :<C-u>bprev<CR>

" コマンドモードでクリップボードのデータを貼り付け
cnoremap <C-v> <C-r>+

" Emacs keybind on command mode
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-g> :<C-u><Esc><CR>
" Delete without line end
cnoremap <expr> <C-d> (getcmdpos()==strlen(getcmdline())+1 ? "\<C-d>" : "\<Del>")

" Omni completion without select first matching
inoremap <C-o> <C-x><C-o><C-p>

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

call neobundle#begin(expand(s:vimfiles . '/bundle'))

NeoBundleFetch 'Shougo/neobundle.vim'

" vimproc Windows環境ではKaoriya付属のものを使用
if !has('win32') && !has('win64')
  NeoBundle 'Shougo/vimproc', {
    \   'build': {
    \     'mac'  : 'make -f make_mac.mak',
    \     'unix' : 'make -f make_unix.mak'
    \   }
    \ }
endif

" vimdoc-ja
if has('unix')
  NeoBundle 'vim-jp/vimdoc-ja'
  set helplang=ja,en
endif

let g:neobundle#default_options = {
  \   '_' : {'verbose': 1, 'focus': 1},
  \   'help': {'lazy': 1, 'autoload': {'filetypes': 'help'}},
  \   'javascript': {'lazy': 1, 'autoload': {'filetypes': 'javascript'}},
  \   'scala': {'lazy': 1, 'autoload': {'filetypes': 'scala'}}
  \ }

NeoBundle 'Yggdroot/indentLine'
NeoBundle 'bling/vim-airline'
NeoBundle 'bling/vim-bufferline'
NeoBundle 'dannyob/quickfixstatus'
NeoBundle 'fuenor/qfixhowm'
NeoBundle 'jceb/vim-hier'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'kana/vim-textobj-line'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'mhinz/vim-signify'
NeoBundle 'nsf/gocode' " error lazy loading on Windows
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundleLazy 'Shougo/neocomplete.vim'
NeoBundleLazy 'Shougo/neosnippet'
NeoBundleLazy 'Shougo/unite-outline'
NeoBundleLazy 'Shougo/unite.vim'
NeoBundleLazy 'Shougo/vimfiler'
NeoBundleLazy 'Shougo/vimshell'
NeoBundleLazy 'derekwyatt/vim-scala', '', 'scala'
NeoBundleLazy 'jelera/vim-javascript-syntax', '', 'javascript'
NeoBundleLazy 'jiangmiao/simple-javascript-indenter', '', 'javascript'
NeoBundleLazy 'junegunn/vim-easy-align'
NeoBundleLazy 'kannokanno/previm'
NeoBundleLazy 'kmnk/vim-unite-giti'
NeoBundleLazy 'majutsushi/tagbar'
NeoBundleLazy 'osyo-manga/unite-quickfix'
NeoBundleLazy 'scrooloose/syntastic'
NeoBundleLazy 'thinca/vim-ft-help_fold', '', 'help'
NeoBundleLazy 'thinca/vim-quickrun'
NeoBundleLazy 'thinca/vim-scouter'
NeoBundleLazy 'tpope/vim-fireplace'

call neobundle#local(expand('$GOROOT/misc'), {'name': 'go'}, ['vim'])

" colorscheme
NeoBundle 'Pychimp/vim-sol'
NeoBundle 'jnurmine/Zenburn'
NeoBundle 'jonathanfilip/vim-lucius'
NeoBundle 'vim-scripts/freya'
NeoBundle 'vim-scripts/swamplight'

" Shougo/neocomplete.vim {{{
if neobundle#tap('neocomplete.vim')
  call neobundle#config({
    \   'lazy': 1,
    \   'autoload': {'insert': 1},
    \   'disabled': !has('lua'),
    \   'vim_version' : '7.3.885'
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neocomplete#data_directory = expand(s:vimfiles . '/.cache/neocomplete')
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_ignore_case = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#force_overwrite_completefunc = 1
    let g:neocomplete#max_list = 20

    let g:neocomplete#keyword_patterns = get(g:, 'neodomplete#keywork_patterns', {})
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    call neocomplete#custom#source('omni', 'disabled_filetypes', {'clojure': 1})
  endfunction

  call neobundle#untap()
endif
"}}}

" Shougo/neosnippet {{{
if neobundle#tap('neosnippet')
  call neobundle#config({
    \   'depends': ['Shougo/neocomplete.vim', 'Shougo/neosnippet-snippets'],
    \   'lazy': 1,
    \   'autoload': {
    \     'insert': 1,
    \     'mappings': '<Plug>(neosnippet_'
    \   }
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neosnippet#data_directory = expand(s:vimfiles . '/.cache/neosnippet')
    let g:neosnippet#snippets_directory = expand(s:vimfiles . '/bundle/neosnippet-snippets/snippets')

    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif

    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)

    " snippet操作中にTabキーで次のフィールドに移動
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

    " Delete merkers when InsertLeave
    autocmd MyAutoCmd InsertLeave * NeoSnippetClearMarkers
  endfunction

  call neobundle#untap()
endif
"}}}

" Shougo/unite-outline {{{
if neobundle#is_installed('unite-outline')
  call neobundle#config('unite-outline', {
    \   'lazy': 1,
    \   'autoload': {'unite_sources': 'outline'}
    \ })

  nnoremap <silent> [option]o :<C-u>Unite outline:filetype -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>
  autocmd MyAutoCmd FileType vim nnoremap <buffer> <silent> [option]o :<C-u>Unite outline:folding -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>
endif
"}}}

" Shougo/unite.vim {{{
if neobundle#tap('unite.vim')
  call neobundle#config({
    \   'depends': 'Shougo/neomru.vim',
    \   'lazy': 1,
    \   'autoload': {'commands': 'Unite'}
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    " Shougo/neomru.vim
    let g:neomru#file_mru_path = expand(s:vimfiles . '/.cache/neomru/file')
    let g:neomru#directory_mru_path = expand(s:vimfiles . '/.cache/neomru/directory')

    let g:unite_data_directory = expand(s:vimfiles . '/.cache/unite')
    let g:unite_enable_start_insert = 1
    let g:unite_split_rule = 'botright'
    let g:unite_winheight = 10

    let g:unite_source_file_mru_ignore_pattern = ''
    let g:unite_source_file_mru_ignore_pattern .= '\~$'
    let g:unite_source_file_mru_ignore_pattern .= '\|\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)'
    if has('win32') || has('win64')
      let g:unite_source_file_mru_ignore_pattern .= '\|AppData/Local/Temp'
      let g:unite_source_file_mru_ignore_pattern .= '\|^//'
    endif

    let g:unite_source_menu_menus = get(g:, 'unite_source_menu_menus', {})
    let g:unite_source_alias_aliases = get(g:, 'unite_source_alias_aliases', {})

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
      \   ['pull',           'Gpull'],
      \   ['push',           'Gpush'],
      \   ['remove',         'Gremove'],
      \   ['status',         'Gstatus'],
      \ ]
    let g:unite_source_alias_aliases.fugitive = {'source': 'menu'}

    if executable('lein') "{{{
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
    endif
    " }}}

    autocmd MyAutoCmd FileType unite call s:unite_my_settings()
    function! s:unite_my_settings()
      imap <buffer><expr> <C-s> unite#do_action('split')
      " Quit
      nmap <buffer> q <Plug>(unite_exit)
      nmap <buffer> <C-q> <Plug>(unite_exit)
      imap <buffer> <C-q> <Plug>(unite_exit)
      " Ctrlp like
      imap <buffer> <C-j> <Plug>(unite_select_next_line)
      imap <buffer> <C-k> <Plug>(unite_select_previous_line)
      " Emacs like
      imap <buffer> <C-b> <Left>
      imap <buffer> <C-f> <Right>
      imap <buffer> <C-a> <Home>
      imap <buffer> <C-e> <End>
      imap <buffer> <C-d> <Del>
    endfunction
  endfunction

  nnoremap <silent>[option]u :<C-u>Unite buffer bookmark file file_mru<CR>
  nnoremap <silent>[option]/ :<C-u>Unite line<CR>
  nnoremap <silent>[option]g :<C-u>Glcd \| execute('Unite fugitive:fugitive giti')<CR>
  if executable('lein')
    autocmd MyAutoCmd FileType clojure nnoremap <buffer><silent>[option]m :<C-u>Unite menu:lein<CR>
  endif

  call neobundle#untap()
endif
" }}}

" Shougo/vimfiler {{{
if neobundle#is_installed('vimfiler')
  call neobundle#config('vimfiler', {
    \   'depends': 'Shougo/unite.vim',
    \   'lazy': 1,
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimFiler', 'complete': 'customhist,vimfiler#complete'},
    \       'VimFilerBufferDir', 'Edit', 'Read', 'Source', 'Write'
    \     ],
    \     'mappings': '<Plug>(vimfiler_',
    \     'explorer': 1
    \   }
    \ })

  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_data_directory = expand(s:vimfiles . '/.cache/vimfiler')
  let g:vimfiler_safe_mode_by_default = 0
  let g:vimfiler_tree_indentation = 2
  let g:vimfiler_tree_leaf_icon = ' '

  " 現在開いているバッファをIDE風に開く
  nnoremap <silent>[option]f :<C-u>VimFilerBufferDir -buffer-name=explorer -explorer -split -simple -toggle -winwidth=35 -no-quit<CR>
endif
"}}}

" Shougo/vimshell {{{
if neobundle#tap('vimshell')
  call neobundle#config({
    \   'lazy': 1,
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimShell', 'complete': 'customlist,vimshell#complete'},
    \       'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop', 'VimShellTab'
    \     ],
    \     'mappings': '<Plug>(vimshell_'
    \   }
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:vimshell_prompt = ((has('win32') || has('win64')) ? $USERNAME : $USER) . '% '
    let g:vimshell_split_command = 'split'
    let g:vimshell_temporary_directory = expand(s:vimfiles . '/.cache/vimshell')
    let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'

    if has('win32') || has('win64')
      autocmd MyAutoCmd FileType vimshell setlocal fileencoding=cp932

      if executable('lein')
        call vimshell#util#set_variables({'$LEIN_JVM_OPTS': '-Djline.terminal=jline.UnsupportedTerminal'})
      endif
    endif
  endfunction

  nnoremap <silent>[option]s :<C-u>VimShell -split<CR>

  call neobundle#untap()
endif
"}}}

" Yggdroot/indentLine {{{
if neobundle#is_installed('indentLine')
  call neobundle#config('indentLine', {
    \   'disabled': !has('conceal')
    \ })
endif
" }}}

" bling/vim-airline, vim-bufferline {{{
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

let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#branch#enabled = 0

" statusline設定を抑制
let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0

" vim-quickrunが終了しない点防止用
let g:bufferline_echo = 0
"}}}

" fuenor/qfixhowm {{{
if neobundle#is_installed('qfixhowm')
  let g:QFixHowm_Convert = 0
  let g:QFixHowm_HolidayFile = expand(s:vimfiles . '/bundle/qfixhowm/misc/holiday/Sche-Hd-0000-00-00-000000.utf8')
  let g:QFixMRU_Filename = expand(s:vimfiles . '/.cache/qfixmru')
  let g:disable_QFixWin = 1
  let g:qfixmemo_dir = expand('~/memo')
  let g:qfixmemo_ext = 'md'
  let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d-%H%M%S'
  let g:qfixmemo_filetype = ''
  let g:qfixmemo_mapleader = 'm'
  let g:qfixmemo_template = [
    \   substitute('%TITLE% [] <_1_>', '_', '`', 'g'),
    \   '%DATE%',
    \   '',
    \   substitute('<_0_>', '_', '`', 'g')
    \ ]
  let g:qfixmemo_template_keycmd = '$F[a'
  let g:qfixmemo_timeformat = 'last update: %Y-%m-%d %H:%M'
  let g:qfixmemo_timeformat_regxp = '^last update: \d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}'
  let g:qfixmemo_timestamp_regxp  = g:qfixmemo_timeformat_regxp
  let g:qfixmemo_title = '#'
  let g:qfixmemo_use_howm_schedule = 0
  let g:qfixmemo_use_updatetime = 1
  if (has('win32') || has('win64')) && !executable('grep')
    let mygreparg = 'findstr'
    let myjpgrepprg = 'agrep.vim'
  endif

  noremap mt :<C-u>call howm_schedule#QFixHowmSchedule('todo', expand('~/memo'), 'utf-8')<CR>
endif
"}}}

" jiangmiao/auto-pairs {{{
let g:AutoPairsMapSpace = 0
"}}}

" kmnk/vim-unite-giti {{{
if neobundle#is_installed('vim-unite-giti')
  call neobundle#config('vim-unite-giti', {
    \   'lazy': 1,
    \   'autoload': {'unite_sources': 'giti'}
    \ })
endif
"}}}

" junegunn/vim-easy-align {{{
if neobundle#is_installed('vim-easy-align')
  call neobundle#config('vim-easy-align', {
    \   'lazy': 1,
    \   'autoload': {
    \     'commands': ['EasyAlign', 'LiveEasyAlign'],
    \     'mappings': '<Plug>(EasyAlign)'
    \   }
    \ })
  vmap <Enter> <Plug>(EasyAlign)
endif
"}}}

" kannokanno/previm {{{
if neobundle#is_installed('previm')
  call neobundle#config('previm', {
    \   'depends': 'tyru/open-browser.vim',
    \   'lazy': 1,
    \   'autoload': {'commands': 'PrevimOpen'}
    \ })
  autocmd MyAutoCmd FileType markdown nnoremap <silent> <buffer> [option]p :<C-u>PrevimOpen<CR>
endif
"}}}

" kien/ctrlp.vim {{{
let g:ctrlp_cache_dir = expand(s:vimfiles . '/.cache/ctrlp')
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_custom_ignore = {
  \   'file': '\v\.(dll|exe|jar|so)$',
  \   'dir': '\v[\\/](out|repl|target)$'
  \ }
let g:ctrlp_map = '<C-@>'
" C-hでBackspace (カーソル移動からC-hを除外)
let g:ctrlp_prompt_mappings = {
  \   'PrtBS()': ['<bs>', '<C-h>', '<C-]>'],
  \   'PrtCurLeft()': ['<left>', '<C-^>']
  \ }
let g:ctrlp_use_migemo = 1
"}}}

" kien/rainbow_parentheses.vim {{{
if neobundle#is_installed('rainbow_parentheses.vim')
  autocmd MyAutoCmd VimEnter * RainbowParenthesesToggle
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadRound
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadSquare
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadBraces
endif
"}}}

" majutsushi/tagbar {{{
if neobundle#tap('tagbar')
  call neobundle#config({
    \   'autoload': {'commands': 'TagbarToggle'}
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    if executable('gotags') "{{{
      let g:tagbar_type_go = {
        \   'ctagstype' : 'go',
        \   'kinds': [
        \     'p:package',
        \     'i:imports:1',
        \     'c:constants',
        \     'v:variables',
        \     't:types',
        \     'n:interfaces',
        \     'w:fields',
        \     'e:embedded',
        \     'm:methods',
        \     'r:constructor',
        \     'f:functions'
        \   ],
        \   'sro': '.',
        \   'kind2scope': {
        \     't': 'ctype',
        \     'n': 'ntype'
        \   },
        \   'scope2kind': {
        \     'ctype': 't',
        \     'ntype': 'n'
        \   },
        \   'ctagsbin': 'gotags',
        \   'ctagsargs': '-sort -silent'
        \ }
    endif "}}}
  endfunction

  nnoremap [option]t :<C-u>TagbarToggle<CR>
  call neobundle#untap()
endif
"}}}

" nsf/gocode {{{
if neobundle#tap('gocode')
  call neobundle#config({
    \   'rtp': 'vim',
    \   'disabled': !executable('go') || expand('$GOPATH') == ''
    \ })

  if executable('go') && expand('$GOPATH') != ''
    call neobundle#config({
      \   'build': {
      \     'windows': 'go build -ldflags -H=windowsgui && move /Y gocode.exe ' . shellescape(expand('$GOPATH') . '/bin'),
      \     'others': 'go build && mv -f gocode ' . shellescape(expand('$GOPATH') . '/bin')
      \   }
      \ })
  endif

  call neobundle#untap()
endif
" }}}

" osyo-manga/unite-quickfix {{{
if neobundle#is_installed('unite-quickfix')
  call neobundle#config('unite-quickfix', {
    \   'lazy': 1,
    \   'autoload': {'unite_sources': ['quickfix', 'location_list']}
    \ })
endif
"}}}

" scrooloose/syntastic {{{
if neobundle#is_installed('syntastic')
  call neobundle#config('syntastic', {
    \   'lazy': 1,
    \   'autoload': {'filetypes': ['python']}
    \ })
  let g:syntastic_mode_map = {
    \   'mode': 'active',
    \   'active_filetypes': ['python'],
    \   'passive_filetypes': []
    \ }
  let g:syntastic_python_checkers = ['flake8']
endif
"}}}

" thinca/vim-quickrun {{{
if neobundle#tap('vim-quickrun')
  call neobundle#config({
    \   'lazy': 1,
    \   'autoload': {'commands': 'QuickRun'}
   \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:quickrun_config = get(g:, 'quickrun_config', {})

    let g:quickrun_config._ = {
      \   'outputter': 'multi:buffer:quickfix',
      \   'outputter/buffer/split': 'botright 10sp',
      \   'outputter/buffer/running_mark': '(」・ω・)」うー！(/・ω・)/にゃー！',
      \   'outputter/buffer/close_on_empty': 1,
      \   'runner': 'vimproc',
      \   'runner/vimproc/updatetime': 50,
      \   'runner/vimproc/sleep': 0
      \ }

    if executable('CScript')
      let g:quickrun_config.vb = {
        \   'command': 'CScript',
        \   'exec': '%c //Nologo //E:VBScript %s',
        \   'hook/output_encode/encoding': 'cp932',
        \   'outputter/quickfix/errorformat': '%f(%l\\,\ %c)\ Microsoft\ VBScript\ %m'
        \ }

      let g:quickrun_config['javascript.wsh'] = {
        \   'command': 'CScript',
        \   'exec': '%c //Nologo //E:\{16d51579-a30b-4c8b-a276-0ff4dc41e755\} %s',
        \   'hook/output_encode/encoding': 'cp932',
        \   'outputter/quickfix/errorformat': '%f(%l\\,\ %c)\ JavaScript\ %m'
        \ }
    endif

    if has('win32') || has('win64')
      let g:quickrun_config.dosbatch = {'runner': 'system'}
    endif

    " silent syntax checker
    execute 'highlight qf_error_ucurl gui=undercurl guisp=Red'
    let g:hier_hightlight_group_qf = 'qf_error_ucurl'

    let s:silent_quickfix = quickrun#outputter#quickfix#new()
    function! s:silent_quickfix.finish(session)
      call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
      :cclose
      :HierUpdate
      :QuickfixStatusEnable
    endfunction
    call quickrun#register_outputter('silent_quickfix', s:silent_quickfix)
    unlet! s:silent_quickfix

    let s:go_syntaxcheck_exec = ['%c build %o %s:p:t %a']
    if executable('golint')
      call add(s:go_syntaxcheck_exec, 'golint %s:p:t')
    endif
    let s:device_null = has('win32') || has('win64') ? 'NUL' : '/dev/null'
    let g:quickrun_config['go/syntaxcheck'] = {
      \   'type': 'go',
      \   'exec': s:go_syntaxcheck_exec,
      \   'cmdopt': '-o ' . s:device_null,
      \   'outputter': 'silent_quickfix'
      \ }
    unlet! s:device_null
    unlet! s:go_syntaxcheck_exec

    autocmd MyAutoCmd FileType quickrun nnoremap <buffer> q :quit<CR>
  endfunction

  nnoremap <silent>[option]q :<C-u>QuickRun<CR>

  if executable('go')
    autocmd MyAutoCmd BufWritePost *.go :QuickRun go/syntaxcheck
  endif

  call neobundle#untap()
endif

"}}}

" thinca/vim-scouter {{{
if neobundle#is_installed('vim-scouter')
  call neobundle#config('vim-scouter', {
    \   'lazy': 1,
    \   'autoload': {'commands': 'Scouter'}
    \ })
endif
"}}}

" tpope/vim-fireplace {{{
if neobundle#is_installed('vim-fireplace')
  call neobundle#config('vim-fireplace', {
    \   'depends': 'tpope/vim-classpath',
    \   'lazy': 1,
    \   'autoload': {'commands': 'Connect'},
    \   'disabled': !has('python')
    \ })

  " tpope/vim-classpath
  let g:classpath_cache = expand(s:vimfiles . '/.cache/classpath')
endif
"}}}

" $GOROOT/misc/vim {{{
if neobundle#is_installed('go')
  if executable('goimports')
    let g:gofmt_command = 'goimports'
  endif
  autocmd MyAutoCmd FileType go autocmd BufWritePre <buffer> Fmt
endif
" }}}

call neobundle#end()

"}}}

" JSONデータを整形 {{{
if neobundle#is_installed('vim-operator-user') && executable('jq')
  function! Op_json_format(motion_wise)
    execute "'[,']" "!jq ."
  endfunction
  call operator#user#define('json-format', 'Op_json_format')
  map X <Plug>(operator-json-format)
endif
"}}}

" Colorscheme for CLI {{{
if neobundle#is_installed('Zenburn')
  if !has('gui_running') && !has('win32') && !has('win64')
    try
      colorscheme zenburn
    catch
    endtry
  endif
endif
" }}}

" Filetypes {{{

autocmd MyAutoCmd FileType text setlocal textwidth=0

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
autocmd MyAutoCmd FileType go nnoremap <buffer> <C-s> :<C-u>call GolangToggleFile("e")<CR>
autocmd MyAutoCmd FileType go nnoremap <buffer> K :<C-u>Godoc<CR>

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
autocmd MyAutoCmd BufNewFile,BufRead *.js.bat setlocal filetype=javascript.wsh fileencoding=sjis
let s:jsbat_template = [
  \   '@if (0)==(0) echo off',
  \   'pushd %~dp0',
  \   'CScript //Nologo //E:{16d51579-a30b-4c8b-a276-0ff4dc41e755} "%~f0" %*',
  \   'popd',
  \   'goto :EOF',
  \   '@end',
  \   '',
  \   '/* vim: set ft=javascript.wsh : */',
  \ ]
autocmd MyAutoCmd BufNewFile *.js.bat call append(0, s:jsbat_template)|normal Gdd{

" VBScript
autocmd MyAutoCmd FileType vb setlocal shiftwidth=4 softtabstop=4 tabstop=4

"}}}

" Finalize {{{

" Load local setting file last
if filereadable(s:vimfiles . '/vimrc_local_last.vim')
  execute 'source' s:vimfiles . '/vimrc_local_last.vim'
endif

" ファイルタイプ関連を有効化
filetype plugin indent on

NeoBundleCheck

if !has('vim_starting')
  call neobundle#call_hook('on_source')
endif

"}}}
