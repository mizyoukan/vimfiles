" Initialize {{{

let s:vimfiles = expand(has('win32') ? '$USERPROFILE/vimfiles' : '$HOME/.vim')
let s:homedir = expand(has('win32') ? '$USERPROFILE' : '$HOME')
let s:cachedir = s:vimfiles . '/.cache'
let s:bundledir = s:vimfiles . '/bundle'

" Prevent to multi boot
if has('gui_running') && has('clientserver') && v:servername == 'GVIM1'
  let s:file = expand('%:p')
  bwipeout
  call remote_send('GVIM', '<ESC>:tabnew ' . s:file . '<CR>')
  call remote_foreground('GVIM')
  quit
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
function! s:KillCurrentBuffer(bang) "{{{
  let l:bn = bufnr('%')
  bprevious
  try
    execute 'bdelete' . a:bang l:bn
  catch /E89:/
    execute 'buffer' l:bn
    echoerr v:exception
  endtry
endfunction "}}}
command! -nargs=0 -bang KillCurrentBuffer call <SID>KillCurrentBuffer('<bang>')

" フォールディングで表示する文字列設定
function! s:mbslen(str) "{{{
  let l:charcount = strlen(a:str)
  let l:mcharcount = strlen(substitute(a:str, ".", "x", "g"))
  return l:mcharcount + (l:charcount - l:mcharcount) / 2
endfunction "}}}
function! MyFoldText() "{{{
  let l:left = getline(v:foldstart) . " ..."
  let l:foldedlinecount = v:foldend - v:foldstart
  let l:right = "[" . l:foldedlinecount . "] "
  let l:numbercolwidth = &fdc + &number * &numberwidth
  let l:linewidth = winwidth(0) - l:numbercolwidth
  let l:spacecount = l:linewidth - s:mbslen(l:left) - strlen(l:right)
  let l:space = l:spacecount > 0 ? repeat(" ", l:spacecount) : ""
  return l:left . l:space . l:right
endfunction "}}}

" Toggle golang impl/test file
function! GolangToggleFile(editcmd)
  let l:currentfile = expand("%")
  if match(l:currentfile, "_test\.go$") >= 0
    let l:openfile = split(l:currentfile, "_test\.go$")[0] . ".go"
  else
    let l:openfile = split(l:currentfile, "\.go$")[0] . "_test.go"
  endif
  execute ":" . a:editcmd l:openfile
endfunction

" Set IME off when insert leave
if executable('fcitx-remote')
  set ttimeoutlen=150
  autocmd MyAutoCmd InsertLeave * call system('fcitx-remote -c')
endif

" Remove line end space
function! s:removeLineEndSpace()
  let l:cursor = getpos('.')
  execute '%s/\s\+$//ge'
  call setpos('.', l:cursor)
endfunction
command! -nargs=0 RemoveLineEndSpace silent call <SID>removeLineEndSpace()

" Capitalize last modified text
function! s:lastModifyCapitalize()
  let l:cursor = getpos('.')
  normal `[v`]U
  call setpos('.', l:cursor)
endfunction
command! -nargs=0 LastModifyCapitalize silent call <SID>lastModifyCapitalize()

"}}}

" Encodings {{{

set encoding=utf-8
set fileencodings=utf-8,cp932,euc-up
if has('win32')
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

" バックアップファイル出力先
let s:backupdir = s:vimfiles . '/.backup'
if !isdirectory(s:backupdir)
  call mkdir(s:backupdir)
endif
let &backupdir = s:backupdir

" スワップファイル出力先
let s:swapdir = s:vimfiles . '/.swap'
if !isdirectory(s:swapdir)
  call mkdir(s:swapdir)
endif
let &directory = s:swapdir

" undoファイル出力先
let &undodir = s:vimfiles . '/.undo'

"}}}

" Key mappings {{{

noremap [option] <Nop>
map <Space> [option]

" 押し辛い位置のキーの代替
noremap [option]h ^
noremap [option]l $
noremap [option]j %

" .vimrc/.gvimrcを編集
if has('win32')
  nnoremap <silent> [option]ev :<C-u>edit $USERPROFILE\vimfiles\.vimrc<CR>
  nnoremap <silent> [option]eg :<C-u>edit $USERPROFILE\vimfiles\.gvimrc<CR>
  nnoremap <silent> [option]el :<C-u>edit $USERPROFILE\vimfiles\vimrc_local.vim<CR>
else
  nnoremap <silent> [option]ev :<C-u>edit ~/.vim/.vimrc<CR>
  nnoremap <silent> [option]eg :<C-u>edit ~/.vim/.gvimrc<CR>
  nnoremap <silent> [option]el :<C-u>edit ~/.vim/vimrc_local.vim<CR>
endif

" .vimrc/.gvimrcを反映
nnoremap <silent> [option]vv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif<CR>
nnoremap <silent> [option]vg :<C-u>if has('gui_running') \| source $MYGVIMRC \| endif<CR>
if has('win32')
  nnoremap [option]vl :<C-u>source $USERPROFILE\vimfiles\vimrc_local.vim<CR>
else
  nnoremap [option]vl :<C-u>source ~/.vim/vimrc_local.vim<CR>
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
cnoremap <C-g> <Esc>
" Delete without line end
cnoremap <expr> <C-d> (getcmdpos()==strlen(getcmdline())+1 ? "\<C-d>" : "\<Del>")

" Omni completion without select first matching
inoremap <C-o> <C-x><C-o><C-p>

"}}}

" NeoBundle {{{

let s:neobundledir = s:bundledir . '/neobundle.vim'
if executable('git') && !isdirectory(s:neobundledir)
  echo 'install NeoBundle ...'
  call mkdir(iconv(s:bundledir, &encoding, &termencoding), 'p')
  call system('git clone https://github.com/Shougo/neobundle.vim ' . shellescape(s:neobundledir))
endif

if has('vim_starting')
  let &runtimepath = &runtimepath . ',' . s:neobundledir
endif

call neobundle#begin(s:bundledir)

NeoBundleFetch 'Shougo/neobundle.vim'

" vimproc Windows環境ではKaoriya付属のものを使用
if has('mac') || has('unix')
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
  \   'javascript': {'autoload': {'filetypes': 'javascript'}},
  \   'scala': {'autoload': {'filetypes': 'scala'}}
  \ }

NeoBundle 'Yggdroot/indentLine'
NeoBundle 'bling/vim-airline'
NeoBundle 'bling/vim-bufferline'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'dannyob/quickfixstatus'
NeoBundle 'fuenor/qfixhowm'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'kana/vim-textobj-line'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'nsf/gocode' " error lazy loading on Windows
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundleLazy 'Shougo/neocomplete.vim'
NeoBundleLazy 'Shougo/neosnippet'
NeoBundleLazy 'Shougo/unite-outline'
NeoBundleLazy 'Shougo/unite.vim'
NeoBundleLazy 'Shougo/vimfiler'
NeoBundleLazy 'cohama/vim-hier'
NeoBundleLazy 'derekwyatt/vim-scala', '', 'scala'
NeoBundleLazy 'jelera/vim-javascript-syntax', '', 'javascript'
NeoBundleLazy 'jiangmiao/simple-javascript-indenter', '', 'javascript'
NeoBundleLazy 'junegunn/vim-easy-align'
NeoBundleLazy 'kannokanno/previm'
NeoBundleLazy 'kmnk/vim-unite-giti'
NeoBundleLazy 'osyo-manga/unite-quickfix'
NeoBundleLazy 'thinca/vim-quickrun'
NeoBundleLazy 'thinca/vim-scouter'
NeoBundleLazy 'tpope/vim-fireplace'

call neobundle#local(expand('$GOROOT/misc'), {'name': 'go'}, ['vim'])

" colorscheme
NeoBundle 'Pychimp/vim-sol'
NeoBundle 'jnurmine/Zenburn'
NeoBundle 'jonathanfilip/vim-lucius'

" Shougo/neocomplete.vim {{{
if neobundle#tap('neocomplete.vim')
  call neobundle#config({
    \   'autoload': {'insert': 1},
    \   'disabled': !has('lua'),
    \   'vim_version' : '7.3.885'
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neocomplete#data_directory = s:cachedir . '/neocomplete'
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
    \   'autoload': {
    \     'insert': 1,
    \     'mappings': '<Plug>(neosnippet_'
    \   }
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:neosnippet#data_directory = s:cachedir . '/neosnippet'
    let g:neosnippet#snippets_directory = s:bundledir . '/neosnippet-snippets/snippets'

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
    \   'autoload': {'commands': 'Unite'}
    \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    " Shougo/neomru.vim
    let g:neomru#file_mru_path = s:cachedir . '/neomru/file'
    let g:neomru#directory_mru_path = s:cachedir . '/neomru/directory'

    let g:unite_data_directory = s:cachedir . '/unite'
    let g:unite_enable_start_insert = 1
    let g:unite_split_rule = 'botright'
    let g:unite_winheight = 10

    let g:unite_source_file_mru_ignore_pattern = ''
    let g:unite_source_file_mru_ignore_pattern .= '\~$'
    let g:unite_source_file_mru_ignore_pattern .= '\|\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)'
    if has('win32')
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
        \ ]
      return join(l:command, '|')
    endfunction

    let g:unite_source_menu_menus.fugitive = {'description': 'A Git wrapper so awesome, it should be illegal'}
    let g:unite_source_menu_menus.fugitive.command_candidates = [
      \   ['[command?]',     s:unite_menu_input('git> ', 'execute "Git!" . $1')],
      \   ['add',            'Gwrite'],
      \   ['checkout',       'Gread'],
      \   ['commit',         'Gcommit --verbose'],
      \   ['commit --amend', 'Gcommit --amend --verbose'],
      \   ['diff',           'Gdiff'],
      \   ['grep...',        s:unite_menu_input('git grep> ', 'execute("silent Glgrep!" . $1 . " | Unite -auto-preview -auto-resize -winheight=20 location_list")')],
      \   ['move...',        s:unite_menu_input('git mv dest> ', 'execute "Gmove " . $1')],
      \   ['pull',           'Gpull'],
      \   ['pull --rebase',  'Gpull --rebase'],
      \   ['push',           'Gpush'],
      \   ['remove',         'Gremove'],
      \   ['status',         'Gstatus'],
      \ ]
    let g:unite_source_alias_aliases.fugitive = {'source': 'menu'}

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

  call neobundle#untap()
endif
" }}}

" Shougo/vimfiler {{{
if neobundle#is_installed('vimfiler')
  call neobundle#config('vimfiler', {
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

  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_data_directory = s:cachedir . '/vimfiler'
  let g:vimfiler_safe_mode_by_default = 0
  let g:vimfiler_tree_indentation = 2
  let g:vimfiler_tree_leaf_icon = ' '

  " 現在開いているバッファをIDE風に開く
  nnoremap <silent>[option]f :<C-u>VimFilerBufferDir -buffer-name=explorer -explorer -split -simple -toggle -winwidth=35 -no-quit<CR>
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

let g:airline#extensions#branch#enabled = 0

" statusline設定を抑制
let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0

" vim-quickrunが終了しない点防止用
let g:bufferline_echo = 0
"}}}

" cohama/vim-hier {{{
if neobundle#is_installed('vim-hier')
  call neobundle#config('vim-hier', {
    \   'autoload': {'commands': ['HierUpdate', 'HierClear', 'HierStart', 'HierStop']}
    \ })
endif
"}}}

" ctrlpvim/ctrlp.vim {{{
let g:ctrlp_cache_dir = s:cachedir . '/ctrlp'
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

" fuenor/qfixhowm {{{
if neobundle#is_installed('qfixhowm')
  let g:QFixHowm_Convert = 0
  let g:QFixHowm_HolidayFile = s:bundledir . '/qfixhowm/misc/holiday/Sche-Hd-0000-00-00-000000.utf8'
  let g:QFixMRU_Filename = s:cachedir . '/qfixmru'
  let g:disable_QFixWin = 1
  let g:qfixmemo_dir = s:homedir . '/memo'
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
  if has('win32') && !executable('grep')
    let mygreparg = 'findstr'
    let myjpgrepprg = 'agrep.vim'
  endif

  noremap mt :<C-u>call howm_schedule#QFixHowmSchedule('todo', s:homedir . '/memo'), 'utf-8')<CR>
endif
"}}}

" jiangmiao/auto-pairs {{{
let g:AutoPairsMapSpace = 0
"}}}

" kmnk/vim-unite-giti {{{
if neobundle#is_installed('vim-unite-giti')
  call neobundle#config('vim-unite-giti', {
    \   'autoload': {'unite_sources': 'giti'}
    \ })
endif
"}}}

" junegunn/vim-easy-align {{{
if neobundle#is_installed('vim-easy-align')
  call neobundle#config('vim-easy-align', {
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
    \   'autoload': {'commands': 'PrevimOpen'}
    \ })
  autocmd MyAutoCmd FileType markdown nnoremap <silent> <buffer> [option]p :<C-u>PrevimOpen<CR>
endif
"}}}

" kien/rainbow_parentheses.vim {{{
if neobundle#is_installed('rainbow_parentheses.vim')
  autocmd MyAutoCmd VimEnter * RainbowParenthesesToggle
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadRound
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadSquare
  autocmd MyAutoCmd Syntax * RainbowParenthesesLoadBraces
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
    \   'autoload': {'unite_sources': ['quickfix', 'location_list']}
    \ })
endif
"}}}

" thinca/vim-quickrun {{{
if neobundle#tap('vim-quickrun')
  call neobundle#config({
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

    if has('win32')
      let g:quickrun_config.dosbatch = {'runner': 'system'}

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

    " silent syntax checker
    execute 'highlight SilentSyntaxChecker gui=undercurl guisp=Red'
    let g:hier_highlight_group_qf = 'SilentSyntaxChecker'

    let s:silent_quickfix = quickrun#outputter#quickfix#new()
    function! s:silent_quickfix.finish(session)
      call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
      cclose
      HierUpdate
      QuickfixStatusEnable
    endfunction
    call quickrun#register_outputter('silent_quickfix', s:silent_quickfix)

    let s:go_syntaxcheck_exec = ['%c build %o %s:p:t %a']
    if executable('golint')
      call add(s:go_syntaxcheck_exec, 'golint %s:p:t')
    endif
    let s:device_null = has('win32') ? 'NUL' : '/dev/null'
    let g:quickrun_config['go/syntaxcheck'] = {
      \   'type': 'go',
      \   'exec': s:go_syntaxcheck_exec,
      \   'cmdopt': '-o ' . s:device_null,
      \   'outputter': 'silent_quickfix'
      \ }

    autocmd MyAutoCmd FileType quickrun nnoremap <buffer> q :quit<CR>
  endfunction

  nnoremap <silent>[option]q :<C-u>QuickRun<CR>

  if executable('go')
    autocmd MyAutoCmd BufWritePost *.go QuickRun go/syntaxcheck
  endif

  call neobundle#untap()
endif

"}}}

" thinca/vim-scouter {{{
if neobundle#is_installed('vim-scouter')
  call neobundle#config('vim-scouter', {
    \   'autoload': {'commands': 'Scouter'}
    \ })
endif
"}}}

" tpope/vim-fireplace {{{
if neobundle#is_installed('vim-fireplace')
  call neobundle#config('vim-fireplace', {
    \   'depends': 'tpope/vim-classpath',
    \   'autoload': {'filetypes': 'clojure'},
    \   'disabled': !has('python')
    \ })

  " tpope/vim-classpath
  let g:classpath_cache = s:cachedir . '/classpath'

  function! s:myClojureMapping()
    nmap <buffer> <C-CR> <Plug>FireplacePrintip
    vmap <buffer> <C-CR> <Plug>FireplacePrint
  endfunction
  autocmd MyAutoCmd FileType clojure call <SID>myClojureMapping()
endif
"}}}

" $GOROOT/misc/vim {{{
if neobundle#is_installed('go')
  autocmd MyAutoCmd FileType go autocmd BufWritePre <buffer> Fmt
endif
" }}}

call neobundle#end()

"}}}

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
autocmd MyAutoCmd BufNewFile,BufRead *.cljx setlocal filetype=clojure

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

" Load local setting file
if filereadable(s:vimfiles . '/vimrc_local.vim')
  execute 'source' s:vimfiles . '/vimrc_local.vim'
endif

" ファイルタイプ関連を有効化
filetype plugin indent on

NeoBundleCheck

if !has('vim_starting')
  call neobundle#call_hook('on_source')
endif

"}}}
