" Initialize {{{

let s:vimfiles = expand(has('win32') ? '$USERPROFILE/vimfiles' : '$HOME/.vim')

if filereadable(s:vimfiles . '/vimrc_local_pre.vim')
  execute 'source' s:vimfiles . '/vimrc_local_pre.vim'
endif

let s:homedir = expand(has('win32') ? '$USERPROFILE' : '$HOME')
let s:cachedir = s:vimfiles . '/.cache'

let s:has_go = executable('go') && isdirectory(expand('$GOPATH'))

" Directory to save memo files
let s:mymemodir = expand(has('win32') ? '$USERPROFILE' : '$HOME') . '/memo'

let s:mysnippets = s:vimfiles . '/snippets'

" Popup if has already opened other Vim
try
  runtime macros/editexisting.vim
catch /E122:/
endtry

" Prevent to multi boot
if has('gui_running') && has('clientserver') && v:servername == 'GVIM1'
  let s:file = expand('%:p')
  bwipeout
  call remote_send('GVIM', '<ESC>:tabnew ' . s:file . '<CR>')
  call remote_foreground('GVIM')
  quit
endif

let s:bundledir = s:vimfiles . '/bundle'
let s:neobundledir = s:bundledir . '/neobundle.vim'

function! s:bundled(bundle)
  if !isdirectory(s:bundledir)
    return 0
  elseif a:bundle ==# 'neobundle.vim'
    return 1
  else
    return neobundle#is_installed(a:bundle)
  endif
endfunction

augroup MyAutoCmd
  autocmd!
augroup END

"}}}

" NeoBundle {{{

filetype plugin indent off

if !s:bundled('neobundle.vim') && executable('git') && has('iconv')
  echo 'install NeoBundle ...'
  call mkdir(iconv(s:bundledir, &encoding, &termencoding), 'p')
  call system('git clone https://github.com/Shougo/neobundle.vim ' . shellescape(s:neobundledir))
endif

if has('vim_starting') && isdirectory(s:neobundledir)
  let &runtimepath = &runtimepath . ',' . s:neobundledir
endif

if s:bundled('neobundle.vim')
  let g:neobundle#default_options = { '_' : {'verbose': 1}}

  call neobundle#begin(s:bundledir)

  NeoBundleFetch 'Shougo/neobundle.vim'

  " Use bundled plugin when kaoriya
  if !has('kaoriya')
    NeoBundle 'Shougo/vimproc', {
      \   'build': {
      \     'mac'  : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak'
      \   }
      \ }
  endif

  if has('unix')
    NeoBundle 'vim-jp/vimdoc-ja'
    set helplang=ja,en
  endif

  NeoBundle 'Yggdroot/indentLine', {'disabled': !has('conceal')}
  NeoBundle 'basyura/TweetVim', {
    \   'depends': ['tyru/open-browser.vim', 'basyura/twibill.vim']
    \ }
  NeoBundle 'ctrlpvim/ctrlp.vim'
  NeoBundle 'dannyob/quickfixstatus'
  NeoBundle 'jiangmiao/auto-pairs'
  NeoBundle 'kana/vim-operator-user'
  NeoBundle 'kana/vim-textobj-line'
  NeoBundle 'kana/vim-textobj-user'
  NeoBundle 'kien/rainbow_parentheses.vim'
  NeoBundle 'mattn/emmet-vim'
  NeoBundle 'mizyoukan/ctrlp-matcher-gomigemo', 'dev', {
    \   'depends': 'ctrlpvim/ctrlp.vim',
    \   'disabled': !executable('gomigemo-server')
    \ }
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'tpope/vim-fugitive'
  NeoBundle 'tpope/vim-surround'
  NeoBundleLazy 'Shougo/neocomplete.vim', {
    \   'autoload': {'insert': 1},
    \   'disabled': !has('lua'),
    \   'vim_version' : '7.3.885'
    \ }
  NeoBundleLazy 'Shougo/neosnippet', {
    \   'depends': ['Shougo/neocomplete.vim', 'honza/vim-snippets'],
    \   'autoload': {
    \     'insert': 1,
    \     'commands': 'NeoSnippetEdit',
    \     'filename_patterns': '\.snip$',
    \     'mappings': '<Plug>(neosnippet_'
    \   }
    \ }
  NeoBundleLazy 'Shougo/unite-outline', {'autoload': {'unite_sources': 'outline'}}
  NeoBundleLazy 'Shougo/unite.vim', {
    \   'depends': 'Shougo/neomru.vim',
    \   'autoload': {'commands': 'Unite'}
    \ }
  NeoBundleLazy 'Shougo/vimfiler', {
    \   'depends': 'Shougo/unite.vim',
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimFiler', 'complete': 'customhist,vimfiler#complete'},
    \       'VimFilerBufferDir', 'Edit', 'Read', 'Source', 'Write'
    \     ],
    \     'mappings': '<Plug>(vimfiler_',
    \     'explorer': 1
    \   }
    \ }
  NeoBundleLazy 'Shougo/vimshell', {
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimShell', 'complete': 'customlist,vimshell#complete'},
    \       'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop', 'VimShellTab'
    \     ],
    \     'mappings': '<Plug>(vimshell_'
    \   }
    \ }
  NeoBundleLazy 'cohama/vim-hier', {'autoload': {'commands': ['HierUpdate', 'HierClear', 'HierStart', 'HierStop']}}
  NeoBundleLazy 'derekwyatt/vim-scala', {'autoload': {'filetypes': 'scala'}}
  NeoBundleLazy 'jelera/vim-javascript-syntax', {'autoload': {'filetypes': 'javascript'}}
  NeoBundleLazy 'jiangmiao/simple-javascript-indenter', {'autoload': {'filetypes': 'javascript'}}
  NeoBundleLazy 'junegunn/vim-easy-align', {
    \   'autoload': {
    \     'commands': ['EasyAlign', 'LiveEasyAlign'],
    \     'mappings': '<Plug>(EasyAlign)'
    \   }
    \ }
  NeoBundleLazy 'kannokanno/previm', {
    \   'depends': 'tyru/open-browser.vim',
    \   'autoload': {'commands': 'PrevimOpen'}
    \ }
  NeoBundleLazy 'kmnk/vim-unite-giti', {'autoload': {'unite_sources': 'giti'}}
  NeoBundleLazy 'osyo-manga/unite-quickfix', {'autoload': {'unite_sources': ['quickfix', 'location_list']}}
  NeoBundleLazy 'thinca/vim-quickrun', {'autoload': {'commands': 'QuickRun'}}
  NeoBundleLazy 'thinca/vim-scouter', {'autoload': {'commands': 'Scouter'}}
  NeoBundleLazy 'tpope/vim-fireplace', {
    \   'autoload': {'filetypes': 'clojure'},
    \   'disabled': !executable('lein') || !has('python')
    \ }

  if s:has_go
    NeoBundleLazy 'vim-jp/vim-go-extra', {'autoload': {'filetypes': 'go'}}
    NeoBundle 'nsf/gocode', {
      \   'rtp': 'vim',
      \   'build': {
      \     'windows': 'go build -ldflags -H=windowsgui && move /Y gocode.exe ' . shellescape(expand('$GOPATH') . '/bin'),
      \     'others': 'go build && mv -f gocode ' . shellescape(expand('$GOPATH') . '/bin')
      \   }
      \ }
  endif

  " colorscheme
  NeoBundle 'Pychimp/vim-sol'
  NeoBundle 'jnurmine/Zenburn'
  NeoBundle 'jonathanfilip/vim-lucius'

  call neobundle#end()

  NeoBundleCheck

  if !has('vim_starting')
    call neobundle#call_hook('on_source')
  endif
endif

filetype plugin indent on

"}}}

" Options {{{

syntax enable

set ambiwidth=double
set autoindent
set autoread
set backspace=indent,eol,start
set clipboard=unnamed,unnamedplus
set completeopt=menuone
set noequalalways
set expandtab
set hidden
set hlsearch
set ignorecase
set iminsert=0
set imsearch=0
set incsearch
set laststatus=2
set list lcs=tab:^_,trail:_
set mouse=a
set nrformats=hex
set nonumber
set scrolloff=5
set shiftwidth=2
set showcmd
set smartcase
set smartindent
set softtabstop=2
set splitright splitbelow
set t_Co=256
set tabstop=2
set textwidth=0
set title
set wildignore=.git,.hg,.svn
set wildignore+=*.bmp,*.jpg,*.jpeg,*.png,*.gif
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.so,*.out,*.class
set wildignore+=*.swp,*.swo,*.swn
set wildignore+=*.DS_Store
set wildmenu
set nowrap

let &termencoding = &encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp932,euc-up
if has('win32')
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif

function! s:mbslen(str) "{{{
  let l:charcount = strlen(a:str)
  let l:mcharcount = strlen(substitute(a:str, ".", "x", "g"))
  let l:hankanacount = strlen(substitute(substitute(a:str, "[^ｦ-ﾟ]", "", "g"), ".", "x", "g"))
  return l:mcharcount + (l:charcount - l:mcharcount) / 2 - l:hankanacount
endfunction "}}}

function! GetColumnNumber(expr) "{{{
  let l:col = col(a:expr)
  let l:line = getline(a:expr)
  if l:line ==# ''
    return 1
  endif
  let l:colchars = matchstr(l:line, '.\{1,' . strchars(l:line[:l:col-1]) . '\}')
  let l:dispwidth = strdisplaywidth(l:colchars)
  if mode() ==# 'i' && strlen(l:line) == (l:col - 1)
    let l:dispwidth += 1
  endif
  return l:dispwidth
endfunction "}}}

function! MyStatusLine(isactive) "{{{
  if a:isactive
    let l:activebuf = bufnr('%')
    let l:bufs = filter(range(1, bufnr('$')),
      \   'buflisted(v:val)'
      \ . ' && v:val != l:activebuf'
      \ . ' && getbufvar(v:val, "&modifiable")'
      \ )
    let l:dispbufs = len(l:bufs) > 0
      \ ? "[" . join(map(l:bufs,
      \       'v:val . ":"'
      \     . ' . fnamemodify(bufname(v:val), ":t")'
      \     . ' . (getbufvar(v:val, "&modified") ? "+" : "")'
      \   ), "|") . "]"
      \ : ""
  else
    let l:dispbufs = ''
  endif
  let l:divchars = has('gui_running') ? ['»', '«'] : ['>', '<']
  return '[%n]%t %m%r%h%w%<' . l:dispbufs . l:divchars[0] . '%='
    \ . l:divchars[1] . '%y[%{&fenc}/%{&ff}] %p%% %l:%{GetColumnNumber(".")}'
endfunction "}}}

function! s:refreshStatusLine() "{{{
  let l:activewin = winnr()
  for l:n in range(1, winnr('$'))
    call setwinvar(l:n, '&statusline', '%!MyStatusLine(' . (l:n == l:activewin) . ')')
  endfor
endfunction "}}}
autocmd MyAutoCmd BufEnter,WinEnter * call <SID>refreshStatusLine()

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
set fillchars=vert:\|
set foldcolumn=0
set foldmethod=marker
set foldopen&
set foldopen-=block
set foldtext=MyFoldText()

function! s:letandmkdir(var, path) "{{{
  try
    if !isdirectory(a:path)
      call mkdir(a:path, 'p')
    endif
  catch
    echohl WarningMsg
    echom '[error] failed to mkdir: ' . a:path
    echohl None
  endtry
  execute printf("let %s = a:path", a:var)
endfunction "}}}

call s:letandmkdir('&backupdir', s:vimfiles . '/.backup')
call s:letandmkdir('&directory', s:vimfiles . '/.swap')
call s:letandmkdir('&undodir', s:vimfiles . '/.undo')

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

" Create memo file
function! s:memonew() "{{{
  if !isdirectory(s:mymemodir)
    echomsg "Memo dir '" . s:mymemodir . "' is not exist, please makedir."
    return
  endif
  let l:cmd = getbufvar('%', '&modified') ? 'split' : 'edit'
  let l:memofile = s:mymemodir . strftime('/%Y/%m/%Y-%m-%d-%H%M%S.md', localtime())
  let l:memodir = fnamemodify(l:memofile, ':p:h')
  let l:memotemplate = [
    \   substitute('# [] <_1_>', '_', '`', 'g'),
    \   '',
    \   substitute('<_2_>', '_', '`', 'g')
    \ ]
  if !isdirectory(l:memodir)
    call mkdir(l:memodir, 'p')
  endif
  execute l:cmd l:memofile
  call append(0, l:memotemplate)
  normal ggf]
  startinsert
endfunction "}}}
command! -nargs=0 MemoNew call <SID>memonew()

"}}}

" Key mappings {{{

" Create empty map
noremap <Space> <Nop>

" Replace key because hard to type
noremap <Space>h ^
noremap <Space>l $
noremap <Space>j %

nnoremap Y y$

" Highlight off
nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Select command history
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" Toggle folding
noremap <Space>a za
" close folding without current cursor
noremap <Space>i zMzv

" Toggle wrap
nnoremap <Space>w :set invwrap<CR>

" Swap j,k and gj,gk
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap gj j
vnoremap gk k

" Use very magic on search
nnoremap / /\v

" Change local cd to current buffer's dir
nnoremap <silent> <Space>cd :<C-u>lcd %:p:h<CR>:pwd<CR>

" Select buffer list
nnoremap <C-n> :<C-u>bnext<CR>
nnoremap <C-p> :<C-u>bprev<CR>

" Paste clipboard text
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
inoremap <C-x><C-o> <C-x><C-o><C-p>

" Edit/source to .vimrc/.gvimrc
if has('win32')
  nnoremap <silent> <Space>ev :<C-u>edit $USERPROFILE\vimfiles\.vimrc<CR>
  nnoremap <silent> <Space>eg :<C-u>edit $USERPROFILE\vimfiles\.gvimrc<CR>
  nnoremap <silent> <Space>el :<C-u>edit $USERPROFILE\vimfiles\vimrc_local.vim<CR>
else
  nnoremap <silent> <Space>ev :<C-u>edit ~/.vim/.vimrc<CR>
  nnoremap <silent> <Space>eg :<C-u>edit ~/.vim/.gvimrc<CR>
  nnoremap <silent> <Space>el :<C-u>edit ~/.vim/vimrc_local.vim<CR>
endif

nnoremap <silent> <Space>vv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif<CR>
nnoremap <silent> <Space>vg :<C-u>if has('gui_running') \| source $MYGVIMRC \| endif<CR>
if has('win32')
  nnoremap <Space>vl :<C-u>source $USERPROFILE\vimfiles\vimrc_local.vim<CR>
else
  nnoremap <Space>vl :<C-u>source ~/.vim/vimrc_local.vim<CR>
endif

nnoremap mc :<C-u>MemoNew<CR>

"}}}

" Filetypes {{{

autocmd MyAutoCmd BufEnter * setlocal formatoptions& fo-= fo-=o
autocmd MyAutoCmd FileType * setlocal textwidth=0
" Set IME off when insert leave
autocmd MyAutoCmd InsertLeave * setlocal iminsert=0 imsearch=0
if executable('fcitx-remote')
  set ttimeoutlen=150
  autocmd MyAutoCmd InsertLeave * call system('fcitx-remote -c')
endif


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

" Snippet
autocmd MyAutoCmd FileType neosnippet setlocal noexpandtab

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
autocmd MyAutoCmd FileType go nnoremap <buffer> K :<C-u>Godoc<CR>

" Clojure
let g:clojure_align_multiline_strings = 1
autocmd MyAutoCmd BufNewFile,BufRead *.cljx setfiletype clojure

" Groovy
autocmd MyAutoCmd BufNewFile,BufRead *.gradle setfiletype groovy

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

" Plugins {{{

" Shougo/neocomplete.vim {{{
if s:bundled('neocomplete.vim')
  let s:bundle = neobundle#get('neocomplete.vim')
  function! s:bundle.hooks.on_source(bundle)
    let g:neocomplete#data_directory = s:cachedir . '/neocomplete'
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_ignore_case = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#force_overwrite_completefunc = 1
    let g:neocomplete#max_list = 20

    let g:neocomplete#keyword_patterns = get(g:, 'neodomplete#keywork_patterns', {})
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    call neocomplete#custom#source('omni', 'disabled_filetypes', {'go': 1, 'clojure': 1})
  endfunction
  unlet s:bundle
endif
"}}}

" Shougo/neosnippet {{{
if s:bundled('neosnippet')
  let s:bundle = neobundle#get('neosnippet')
  function! s:bundle.hooks.on_source(bundle)
    let g:neosnippet#disable_runtime_snippets = {'_': 1}
    let g:neosnippet#enable_snipmate_compatibility = 1

    let g:neosnippet#data_directory = s:cachedir . '/neosnippet'
    let g:neosnippet#snippets_directory = [
      \   s:bundledir . '/vim-snippets/snippets',
      \   s:mysnippets
      \ ]

    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif

    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)

    imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

    " Delete merkers when InsertLeave
    autocmd MyAutoCmd InsertLeave * NeoSnippetClearMarkers
  endfunction
  unlet s:bundle
endif
"}}}

" Shougo/unite-outline {{{
if s:bundled('unite-outline')
  nnoremap <silent> <Space>o :<C-u>Unite outline:filetype -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>
  autocmd MyAutoCmd FileType vim nnoremap <buffer> <silent> <Space>o :<C-u>Unite outline:folding -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>
endif
"}}}

" Shougo/unite.vim {{{
if s:bundled('unite.vim')
  let s:bundle = neobundle#get('unite.vim')
  function! s:bundle.hooks.on_source(bundle)
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

    if executable('git')
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
    endif

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
  unlet s:bundle

  nnoremap <silent><Space>u :<C-u>Unite buffer bookmark file file_mru<CR>
  nnoremap <silent><Space>/ :<C-u>Unite line<CR>
  if executable('git')
    nnoremap <silent><Space>g :<C-u>Glcd \| execute('Unite fugitive:fugitive giti')<CR>
  endif
endif
" }}}

" Shougo/vimfiler {{{
if s:bundled('vimfiler')
  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_data_directory = s:cachedir . '/vimfiler'
  let g:vimfiler_safe_mode_by_default = 0
  let g:vimfiler_tree_indentation = 2
  let g:vimfiler_tree_leaf_icon = ' '

  nnoremap <silent><Space>f :<C-u>VimFilerBufferDir -buffer-name=explorer -explorer -split -simple -toggle -winwidth=35 -no-quit<CR>
endif
"}}}

" Shougo/vimshell {{{
if s:bundled('vimshell')
  let s:bundle = neobundle#get('vimshell')
  function! s:bundle.hooks.on_source(bundle)
    let g:vimshell_temporary_directory = s:cachedir . '/vimshell'
    let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'

    autocmd MyAutoCmd FileType lisp vnoremap <buffer> <C-CR> :VimShellSendString<CR>
  endfunction
  unlet s:bundle
endif
"}}}

" basyura/TweetVim {{{
if s:bundled('TweetVim')
  nnoremap <Space>tw :<C-u>TweetVimSay<CR>
endif
" }}}

" ctrlpvim/ctrlp.vim {{{
if s:bundled('ctrlp.vim')
  let g:ctrlp_cache_dir = s:cachedir . '/ctrlp'
  let g:ctrlp_clear_cache_on_exit = 0
  let g:ctrlp_custom_ignore = {
    \   'file': '\v\.(dll|exe|jar|so)$',
    \   'dir': '\v[\\/](out|repl|target)$'
    \ }
  let g:ctrlp_map = '<C-@>'
  " C-h is backspace (prevent to replace cursor move)
  let g:ctrlp_prompt_mappings = {
    \   'PrtBS()': ['<bs>', '<C-h>', '<C-]>'],
    \   'PrtCurLeft()': ['<left>', '<C-^>']
    \ }

  " List memo files
  let s:bundle = neobundle#get('ctrlp.vim')
  function! s:bundle.hooks.on_post_source(bundle) "{{{
    function! s:memotitle(file)
      for l:line in readfile(a:file, '', 1)
        return [fnamemodify(a:file, ':t:r'), l:line[2:]]
      endfor
      return []
    endfunction

    function! s:memocomp(lhs, rhs)
      let l:lhs = join(split(a:lhs[:stridx(a:lhs, "|") - 1], "-"), "")
      let l:rhs = join(split(a:rhs[:stridx(a:rhs, "|") - 1], "-"), "")
      return l:rhs - l:lhs
    endfunction

    function! MemoList()
      if !isdirectory(s:mymemodir)
        echomsg "Memo dir '" . s:mymemodir . "' is not exist, please makedir."
        return []
      endif
      return sort(map(filter(map(split(glob(s:mymemodir . '/**/*.md'), "\n"),
        \ '<SID>memotitle(v:val)'), 'len(v:val) > 0'), 'join(v:val, "|")'), 's:memocomp')
    endfunction

    function! MemoAccept(mode, str)
      call ctrlp#exit()
      let l:file = split(a:str, "|")[0]
      let l:fpath = s:mymemodir . '/' . l:file[:3] . '/' . l:file[5:6] . '/' . l:file . '.md'
      let l:cmd =
        \ a:mode ==# 't' ? 'tabedit' :
        \ a:mode ==# 'h' ? 'split' :
        \ a:mode ==# 'v' ? 'vsplit' :
        \ getbufvar('%', '&modified') ? 'split' : 'edit'
      execute l:cmd l:fpath
    endfunction

    let g:ctrlp_ext_vars = add(get(g:, 'ctrlp_ext_vars', []), {
      \   'init': 'MemoList()',
      \   'accept': 'MemoAccept',
      \   'lname': 'memolist',
      \   'sname': 'memolist',
      \   'type': 'line',
      \   'sort': 0
      \ })

    let s:ctrlp_memolist_id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

    function! s:ctrlp_memolist()
      return s:ctrlp_memolist_id
    endfunction

    command! -nargs=0 MemoList call ctrlp#init(<SID>ctrlp_memolist())
    nnoremap ma :<C-u>MemoList<CR>
  endfunction "}}}
  unlet s:bundle
endif
"}}}

" jiangmiao/auto-pairs {{{
if neobundle#is_installed('auto-pairs')
  let g:AutoPairsMapSpace = 0
  autocmd MyAutoCmd FileType lisp,clojure let b:AutoPairs = {'(':')', '[':']', '{':'}', '"':'"'}
endif
"}}}

" junegunn/vim-easy-align {{{
if s:bundled('vim-easy-align')
  vmap <CR> <Plug>(EasyAlign)
endif
"}}}

" kannokanno/previm {{{
if s:bundled('previm')
  autocmd MyAutoCmd FileType markdown nnoremap <silent> <buffer> <Space>p :<C-u>PrevimOpen<CR>
endif
"}}}

" kien/rainbow_parentheses.vim {{{
if s:bundled('rainbow_parentheses.vim')
  augroup parentheses
    autocmd!
    autocmd VimEnter * RainbowParenthesesToggle
    autocmd Syntax * RainbowParenthesesLoadRound
    autocmd Syntax * RainbowParenthesesLoadSquare
    autocmd Syntax * RainbowParenthesesLoadBraces
  augroup END
endif
"}}}

" mizyoukan/ctrlp-matcher-gomigemo {{{
if s:bundled('ctrlp-matcher-gomigemo')
  if executable('gomigemo-server')
    let g:ctrlp_match_func = {'match': 'ctrlp#matcher#gomigemo#match'}
    let g:ctrlp#matcher#gomigemo#case_insensitive = 1
  endif
endif
" }}}

" thinca/vim-quickrun {{{
if s:bundled('vim-quickrun')
  let s:bundle = neobundle#get('vim-quickrun')
  function! s:bundle.hooks.on_source(bundle)
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

    " Silent syntax checker
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
  unlet s:bundle

  nnoremap <silent><Space>q :<C-u>QuickRun<CR>

  if s:has_go
    autocmd MyAutoCmd BufWritePost *.go QuickRun go/syntaxcheck
  endif
endif

"}}}

" tomtom/tcomment_vim {{{
if s:bundled('tcomment_vim')
  let g:tcomment_types = get(g:, 'tcomment_types', {})
  let g:tcomment_types['markdown'] = '<!-- %s -->'
endif
" }}}

" tpope/vim-fireplace {{{
if s:bundled('vim-fireplace')
  function! s:myClojureMapping()
    nmap <buffer> <C-CR> <Plug>FireplacePrintip
    vmap <buffer> <C-CR> <Plug>FireplacePrint
  endfunction
  autocmd MyAutoCmd FileType clojure call <SID>myClojureMapping()
  autocmd MyAutoCmd FileType clojure command! -nargs=0 Austin :Piggieback (reset! cemerick.austin.repls/browser-repl-env (cemerick.austin/repl-env))
endif
"}}}

" vim-jp/vim-go-extra {{{
if s:bundled('vim-go-extra')
  autocmd MyAutoCmd FileType go autocmd BufWritePre <buffer> Fmt
endif
" }}}

" Pychimp/vim-sol {{{
if s:bundled('vim-sol')
  augroup solcolorscheme
    autocmd!
    autocmd ColorScheme sol highlight Comment guifg=#a0a0a0
    autocmd ColorScheme sol highlight Folded guifg=#8d8d8d
    autocmd ColorScheme sol highlight SpecialKey guifg=#b592e8
    autocmd ColorScheme sol highlight StatusLine guibg=#404040 guifg=#dfdfdf
    autocmd ColorScheme sol highlight StatusLineNC guibg=#8d8d8d guifg=#dfdfdf
  augroup END
endif
" }}}

" }}}

" Finalize {{{

" Load local setting file
if filereadable(s:vimfiles . '/vimrc_local.vim')
  execute 'source' s:vimfiles . '/vimrc_local.vim'
endif

"}}}
