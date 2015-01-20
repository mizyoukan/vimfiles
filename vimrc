" Initialize {{{

let &termencoding = &encoding
set encoding=utf-8
scriptencoding utf-8

let s:vimfiles = expand(has('win32') ? '$USERPROFILE/vimfiles' : '$HOME/.vim')

if filereadable(s:vimfiles . '/vimrc_local_pre.vim')
  execute 'source' s:vimfiles . '/vimrc_local_pre.vim'
endif

" Popup if has already opened other Vim
try
  runtime macros/editexisting.vim
catch /E122:/
endtry

" Prevent to multi boot
if has('gui_running') && has('clientserver') && v:servername ==# 'GVIM1'
  let s:file = expand('%:p')
  bwipeout
  call remote_send('GVIM', '<ESC>:tabnew ' . s:file . '<CR>')
  call remote_foreground('GVIM')
  quit
endif

let s:homedir = expand(has('win32') ? '$USERPROFILE' : '$HOME')
let s:cachedir = s:vimfiles . '/.cache'
let s:bundledir = s:vimfiles . '/bundle'
let s:neobundledir = s:bundledir . '/neobundle.vim'
let s:snippetsdir = s:vimfiles . '/snippets'

let s:has_go = executable('go') && isdirectory(expand('$GOPATH'))

function! s:bundled(bundle) abort
  if !isdirectory(s:bundledir)
    return 0
  elseif a:bundle ==# 'neobundle.vim' && isdirectory(s:neobundledir)
    return 1
  else
    return neobundle#is_installed(a:bundle)
  endif
endfunction

augroup MyAutoCmd
  autocmd!
augroup END

" Avoid loading menu.vim
if &guioptions !~# 'M'
  set guioptions+=M
endif

"}}}

" NeoBundle {{{

filetype plugin indent off

if !s:bundled('neobundle.vim') && executable('git')
  echo 'install NeoBundle ...'
  if !isdirectory(s:bundledir)
    call mkdir(iconv(s:bundledir, &encoding, &termencoding), 'p')
  endif
  call system('git clone https://github.com/Shougo/neobundle.vim ' . shellescape(s:neobundledir))
endif

if has('vim_starting') && isdirectory(s:neobundledir)
  let &runtimepath = &runtimepath . ',' . s:neobundledir
endif

if s:bundled('neobundle.vim')
  call neobundle#begin(s:bundledir)

  NeoBundleFetch 'Shougo/neobundle.vim'

  " Use bundled plugin when windows-kaoriya
  if !has('win32') || !has('kaoriya')
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
  NeoBundle 'mattn/sonictemplate-vim'
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'tpope/vim-fugitive'
  NeoBundle 'tpope/vim-surround'
  NeoBundleLazy 'Shougo/neocomplete.vim', {
    \   'autoload': {'insert': 1},
    \   'disabled': !has('lua'),
    \   'vim_version' : '7.3.885'
    \ }
  NeoBundleLazy 'Shougo/neosnippet', {
    \   'depends': ['Shougo/neocomplete.vim', 'Shougo/neosnippet-snippets'],
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
  NeoBundleLazy 'junegunn/vim-easy-align', {
    \   'autoload': {
    \     'commands': ['EasyAlign', 'LiveEasyAlign'],
    \     'mappings': '<Plug>(EasyAlign)'
    \   }
    \ }
  NeoBundleLazy 'kana/vim-textobj-jabraces', {'autoload': {'mappings': '<Plug>(textobj-jabraces-'}}
  NeoBundleLazy 'kannokanno/previm', {
    \   'depends': 'tyru/open-browser.vim',
    \   'autoload': {'commands': 'PrevimOpen'}
    \ }
  NeoBundleLazy 'kmnk/vim-unite-giti', {'autoload': {'unite_sources': 'giti'}}
  NeoBundleLazy 'mizyoukan/gomigemo-matchers.vim', {
    \   'autoload': {'unite_sources': 'mymemo'},
    \   'disabled': !executable('gmigemo')
    \ }
  NeoBundleLazy 'osyo-manga/vim-anzu', {'autoload': {'mappings': '<Plug>(anzu-'}}
  NeoBundleLazy 'osyo-manga/vim-textobj-multiblock', {'autoload': {'mappings': '<Plug>(textobj-multiblock-'}}
  NeoBundleLazy 'osyo-manga/vim-textobj-multitextobj', {'autoload': {'mappings': '<Plug>(textobj-multitextobj-'}}
  NeoBundleLazy 'osyo-manga/unite-quickfix', {'autoload': {'unite_sources': ['quickfix', 'location_list']}}
  NeoBundleLazy 'thinca/vim-quickrun', {'autoload': {'commands': 'QuickRun'}}
  NeoBundleLazy 'thinca/vim-scouter', {'autoload': {'commands': 'Scouter'}}
  NeoBundleLazy 'tpope/vim-fireplace', {'autoload': {'filetypes': 'clojure'}}
  if !executable('lein') || !has('python')
    NeoBundleDisable 'tpope/vim-fireplace'
  endif

  if s:has_go
    NeoBundleLazy 'vim-jp/vim-go-extra', {'autoload': {'filetypes': 'go'}}
    try
      NeoBundle 'nsf/gocode', {
        \   'rtp': 'vim',
        \   'build': {
        \     'windows': 'go build -ldflags -H=windowsgui && move /Y gocode.exe ' . shellescape(expand('$GOPATH') . '/bin'),
        \     'others': 'go build && mv -f gocode ' . shellescape(expand('$GOPATH') . '/bin')
        \   }
        \ }
    catch /E48:/ " For opening from Linux filer
    endtry
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
set cmdheight=2
set completeopt=menuone
set display=lastline
set noequalalways
set expandtab
set fileencoding=utf-8
set hidden
set hlsearch
set ignorecase
set iminsert=0
set imsearch=0
set incsearch
set laststatus=2
set linebreak
set list lcs=tab:^_,trail:_
set mouse=a
set nrformats=hex
set scrolloff=5
set shiftwidth=2
set showbreak=+\ "
set smartcase
set smartindent
set softtabstop=2
set splitright splitbelow
set synmaxcol=300
set t_Co=256
set tabstop=2
set wildignore=.git/,.hg/,.svn/
set wildignore+=*.bmp,*.jpg,*.jpeg,*.png,*.gif
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.so,*.out,*.class,*.db
set wildignore+=*.swp,*.swo,*.swn
set wildignore+=*.DS_Store
set wildmenu
set nowrap

if has('patch-7.4.338')
  set breakindent
  autocmd MyAutoCmd BufEnter * setlocal breakindentopt=min:20,shift:0
endif

set fileencodings=utf-8,cp932,euc-jp
if has('win32')
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif

let g:mystatusline_ftmap = {
  \   'clojure.clojurescript': 'clojurescript',
  \   'javascript.chakra': 'chakra',
  \   'javascript.jscript': 'jscript'
  \ }

function! MyStatusLine(isactive) abort "{{{
  let l:line = '[%n]%{winnr("$")>1?"[".winnr()."/".winnr("$")."]":""}%t %m%r%h%w%<'

  if a:isactive
    let l:activebuf = bufnr('%')
    let l:bufs = filter(range(1, bufnr('$')),
      \ 'buflisted(v:val) && v:val != l:activebuf && getbufvar(v:val, "&modifiable")')
    if len(l:bufs) > 0
      let l:line .= '[' . join(map(l:bufs, 'v:val . ":" . ' .
        \ 'fnamemodify(bufname(v:val), ":t") . ' .
        \ '(getbufvar(v:val, "&modified") ? "+" : "")'), '|') . ']'
    endif
  endif
  if has('win32') && !has('gui_running')
    let l:line .= '>%=<'
  else
    let l:line .= '»%=«'
  endif

  let l:line .= '%{&ft==#"" ? "" : "[".get(g:mystatusline_ftmap,&ft,&ft)."]"}'
  let l:line .= '[%{&fenc}/%{&ff}] %p%% %l:%c'

  return l:line
endfunction "}}}

function! s:refresh_statusline() abort "{{{
  let l:activewin = winnr()
  for l:n in range(1, winnr('$'))
    call setwinvar(l:n, '&statusline', '%!MyStatusLine(' . (l:n == l:activewin) . ')')
  endfor
endfunction "}}}
autocmd MyAutoCmd BufEnter,WinEnter * call <SID>refresh_statusline()

function! MyFoldText() abort "{{{
  let l:left = getline(v:foldstart) . ' ...'
  let l:foldedlinecount = v:foldend - v:foldstart
  let l:right = '[' . l:foldedlinecount . '] '
  let l:numbercolwidth = &foldcolumn + &number * &numberwidth
  let l:linewidth = winwidth(0) - l:numbercolwidth
  let l:spacecount = l:linewidth - strdisplaywidth(l:left) - strwidth(l:right)
  return l:left . repeat(' ', l:spacecount) . l:right
endfunction "}}}
set fillchars=vert:\|
set foldmethod=marker
set foldopen&
set foldopen-=block
set foldtext=MyFoldText()

function! s:letandmkdir(var, path) abort "{{{
  try
    if !isdirectory(a:path)
      call mkdir(a:path, 'p')
    endif
  catch
    echohl WarningMsg
    echom '[error] failed to mkdir: ' . a:path
    echohl None
  endtry
  execute printf('let %s = a:path', a:var)
endfunction "}}}

call s:letandmkdir('&backupdir', s:vimfiles . '/.backup')
call s:letandmkdir('&directory', s:vimfiles . '/.swap')
call s:letandmkdir('&undodir', s:vimfiles . '/.undo')

"}}}

" Commands and Functions {{{

" Delete current buffer without closing window
function! s:bdelete_currbuf(bang) abort "{{{
  let l:bn = bufnr('%')
  bprevious
  try
    execute 'bdelete' . a:bang l:bn
  catch /E89:/
    execute 'buffer' l:bn
    echoerr v:exception
  endtry
endfunction "}}}
command! -nargs=0 -bang KillCurrentBuffer call <SID>bdelete_currbuf('<bang>')

function! s:foldl(op, state, list) abort
  return eval(join(insert(a:list, a:state), a:op))
endfunction

" Wipeout hidden and nomodified buffers
function! s:bwipeout_ninjaly(bang) abort "{{{
  let l:leave_bufnrs = s:foldl('+', [], map(range(1, tabpagenr('$')), 'tabpagebuflist(v:val)'))
  let l:filter_pred = 'index(l:leave_bufnrs, v:val)==-1 && bufexists(v:val)'
  let l:filter_pred .= a:bang !=# '!' ? ' && !getbufvar(v:val, "&modified")' : ''
  let l:bw_bufnrs = filter(range(1, bufnr('$')), l:filter_pred)
  for l:bufnr in l:bw_bufnrs
    execute 'bwipeout' . a:bang l:bufnr
  endfor
endfunction "}}}
command! -nargs=0 -bang BufferWipeoutNinjaly call <SID>bwipeout_ninjaly('<bang>')

" Remove line end space
function! s:remove_trailing_spaces() abort
  let l:cursor = getpos('.')
  execute '%s/\s\+$//ge'
  call setpos('.', l:cursor)
endfunction
command! -nargs=0 RemoveTrailingSpaces call <SID>remove_trailing_spaces()

" Capitalize last modified text
function! s:capitalize_last_modified() abort
  let l:cursor = getpos('.')
  normal! `[v`]U
  call setpos('.', l:cursor)
endfunction
command! -nargs=0 LastModifiedCapitalize silent call <SID>capitalize_last_modified()

" Rename file
function! s:renameto(file, bang) abort "{{{
  if filereadable(a:file) && a:bang !=# '!'
    echomsg 'File already exists'
  elseif isdirectory(a:file)
    echomsg 'Directory with same name already exists'
  else
    let l:prev = expand('%')
    execute 'saveas' . a:bang a:file
    call delete(l:prev)
    execute 'bdelete' l:prev
  endif
endfunction "}}}
command! -nargs=1 -bang RenameTo call <SID>renameto(<q-args>, '<bang>')

command! -bang MyScouter Scouter<bang> $MYVIMRC

" Reopen file in a different format
command! Utf8 edit ++enc=utf8 %
command! Cp932 edit ++enc=cp932 %
command! Unix edit ++ff=unix %
command! Dos edit ++ff=dos %

" Change local directory to git root
function! s:lcd_gitroot(dir) abort "{{{
  let l:curr = fnamemodify(a:dir, ':p')
  while l:curr !=# fnamemodify(l:curr, ':h')
    if isdirectory(l:curr . '/.git')
      execute 'lcd' l:curr
      pwd
      return
    endif
    let l:curr = fnamemodify(l:curr, ':h')
  endwhile
  echo 'Git root is not found of [' . fnamemodify(a:dir, ':p') . ']'
endfunction "}}}

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
nnoremap <silent> <C-L> :<C-U>nohlsearch<CR><C-L>

" Select command history
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

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
nnoremap <silent> <Space>cd :<C-U>lcd %:p:h<CR>:pwd<CR>

" Change local cd to git root with current buffer's file
nnoremap <silent> <Space>cg :<C-U>call <SID>lcd_gitroot(expand('%'))<CR>

" Select buffer list
nnoremap <C-N> :<C-U>bnext<CR>
nnoremap <C-P> :<C-U>bprev<CR>

" Paste clipboard text
cnoremap <C-V> <C-R>+

" Emacs keybind on command mode
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-G> <Esc>
" Delete without line end
cnoremap <expr> <C-D> (getcmdpos()==strlen(getcmdline())+1 ? '<C-D>' : '<Del>')

" Omni completion without select first matching
inoremap <C-X><C-O> <C-X><C-O><C-P>

" Edit/source vimrc
nnoremap <Space>ev :<C-U>edit $MYVIMRC<CR>
nnoremap <Space>sv :<C-U>split $MYVIMRC<CR>
nnoremap <Space>vv :<C-U>source $MYVIMRC<CR>
nnoremap <Space>eg <Nop>
nnoremap <Space>sg <Nop>
nnoremap <Space>vg <Nop>

" Edit/source local vimrc
if has('win32')
  nnoremap <Space>el :<C-U>edit $USERPROFILE\vimfiles\vimrc_local.vim<CR>
  nnoremap <Space>sl :<C-U>split $USERPROFILE\vimfiles\vimrc_local.vim<CR>
  nnoremap <Space>vl :<C-U>source $USERPROFILE\vimfiles\vimrc_local.vim<CR>
else
  nnoremap <Space>el :<C-U>edit ~/.vim/vimrc_local.vim<CR>
  nnoremap <Space>sl :<C-U>split ~/.vim/vimrc_local.vim<CR>
  nnoremap <Space>vl :<C-U>source ~/.vim/vimrc_local.vim<CR>
endif

nnoremap <Space>v. :<C-U>source %:p<CR>

nnoremap mc :<C-U>MemoNew<CR>
nnoremap ma :<C-U>Unite mymemo<CR>

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

" Set readonly with existing swap file
autocmd MyAutoCmd SwapExists * let v:swapchoice = 'o'

" VimScript
let g:vim_indent_cont = 2
autocmd MyAutoCmd FileType vim command! -nargs=0 Vint cexpr system('vint ' . expand('%'))

" QuickFix
autocmd MyAutoCmd FileType qf nnoremap <buffer> p <CR>zz<C-W>p
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
autocmd MyAutoCmd FileType go nnoremap <buffer> K :<C-U>Godoc<CR>

" Clojure
let g:clojure_align_multiline_strings = 1
let g:clojure_fuzzy_indent_patterns = [
  \   '^with', '^def', '^let',
  \   'context', 'defroutes', 'deftemplate', 'go-loop'
  \ ]
autocmd MyAutoCmd BufNewFile,BufRead *.{cljs,cljx} setlocal filetype=clojure.clojurescript

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
autocmd MyAutoCmd BufRead,BufNewFile *.bat call <SID>ftdetect_jscript()
function! s:ftdetect_jscript() abort "{{{
  if getline(1) =~? '^@if\s*(0)\s*==\s*(0)'
    for l:i in range(2, 5)
      let l:line = getline(l:i)
      if l:line =~? '^CScript.\+//E:{16d51579-a30b-4c8b-a276-0ff4dc41e755}'
        setlocal filetype=javascript.chakra
        return
      elseif l:line =~? '^CScript.\+//E:JScript'
        setlocal filetype=javascript.jscript
        return
      endif
    endfor
  endif
endfunction "}}}

" VBScript
autocmd MyAutoCmd FileType vb setlocal shiftwidth=4 softtabstop=4 tabstop=4

"}}}

" Plugins {{{

" Shougo/neocomplete.vim {{{
if s:bundled('neocomplete.vim')
  let s:bundle = neobundle#get('neocomplete.vim')
  function! s:bundle.hooks.on_source(bundle) abort
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
  function! s:bundle.hooks.on_source(bundle) abort
    let g:neosnippet#disable_runtime_snippets = {'_': 1}
    let g:neosnippet#enable_snipmate_compatibility = 1

    let g:neosnippet#data_directory = s:cachedir . '/neosnippet'
    let g:neosnippet#snippets_directory = [
      \   s:bundledir . '/neosnippet-snippets/neosnippets',
      \   s:snippetsdir
      \ ]

    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif

    imap <C-K> <Plug>(neosnippet_expand_or_jump)
    smap <C-K> <Plug>(neosnippet_expand_or_jump)

    imap <expr> <TAB> neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : pumvisible() ? '<C-N>' : '<TAB>'
    smap <expr> <TAB> neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '<TAB>'

    " Delete merkers when InsertLeave
    autocmd MyAutoCmd InsertLeave * NeoSnippetClearMarkers
  endfunction
  unlet s:bundle
endif
"}}}

" Shougo/unite-outline {{{
if s:bundled('unite-outline')
  nnoremap <silent> <Space>o :<C-U>Unite outline:filetype -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>
  autocmd MyAutoCmd FileType vim nnoremap <silent> <buffer> <Space>o :<C-U>Unite outline:folding -no-start-insert -no-quit -winwidth=35 -direction=rightbelow -vertical<CR>
endif
"}}}

" Shougo/unite.vim {{{
if s:bundled('unite.vim')
  let s:bundle = neobundle#get('unite.vim')
  function! s:bundle.hooks.on_source(bundle) abort
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

    autocmd MyAutoCmd FileType unite call s:unite_my_settings()
    function! s:unite_my_settings() abort
      imap <buffer> <expr> <C-S> unite#do_action('split')
      " Quit
      nmap <buffer> q <Plug>(unite_exit)
      nmap <buffer> <C-Q> <Plug>(unite_exit)
      imap <buffer> <C-Q> <Plug>(unite_exit)
      " Ctrlp like
      imap <buffer> <C-J> <Plug>(unite_select_next_line)
      imap <buffer> <C-K> <Plug>(unite_select_previous_line)
      " Emacs like
      imap <buffer> <C-B> <Left>
      imap <buffer> <C-F> <Right>
      imap <buffer> <C-A> <Home>
      imap <buffer> <C-E> <End>
      imap <buffer> <C-D> <Del>
    endfunction

    call unite#custom#source('mymemo', 'sorters', ['sorter_ftime', 'sorter_reverse'])
    if s:bundled('gomigemo-matchers.vim')
      call unite#custom#source('mymemo', 'matchers', 'matcher_gomigemo')
    endif
  endfunction
  unlet s:bundle

  nnoremap <silent> <Space>u :<C-U>Unite buffer bookmark file file_mru<CR>
  nnoremap <silent> <Space>/ :<C-U>Unite line<CR>
  if executable('git')
    nnoremap <silent> <Space>gf :<C-U>Glcd \| Unite file_rec/git<CR>
    nnoremap <silent> <Space>gg :<C-U>Glcd \| Unite giti<CR>
    nnoremap <silent> <Space>gb :<C-U>Glcd \| Unite giti/branch<CR>
    nnoremap <silent> <Space>gl :<C-U>Glcd \| Unite giti/log -no-start-insert<CR>
    nnoremap <silent> <Space>gs :<C-U>Glcd \| Unite giti/status<CR>
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

  nnoremap <silent> <Space>f :<C-U>VimFilerBufferDir -buffer-name=explorer -explorer -split -simple -toggle -winwidth=35 -no-quit<CR>
endif
"}}}

" Shougo/vimshell {{{
if s:bundled('vimshell')
  let s:bundle = neobundle#get('vimshell')
  function! s:bundle.hooks.on_source(bundle) abort
    let g:vimshell_temporary_directory = s:cachedir . '/vimshell'
    let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'

    autocmd MyAutoCmd FileType lisp vnoremap <buffer> <C-CR> :VimShellSendString<CR>
  endfunction
  unlet s:bundle
endif
"}}}

" basyura/TweetVim {{{
if s:bundled('TweetVim')
  nnoremap <Space>tw :<C-U>TweetVimSay<CR>
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
  " C-H is backspace (prevent to replace cursor move)
  let g:ctrlp_prompt_mappings = {
    \   'PrtBS()': ['<BS>', '<C-H>', '<C-]>'],
    \   'PrtCurLeft()': ['<Left>', '<C-^>']
    \ }

  if executable('files')
    let g:ctrlp_user_command = 'files -p %s'
  endif
endif
"}}}

" jiangmiao/auto-pairs {{{
if neobundle#is_installed('auto-pairs')
  let g:AutoPairsMapSpace = 0
  autocmd MyAutoCmd FileType lisp,clojure let b:AutoPairs = {'(':')', '[':']', '{':'}', '"':'"'}
endif
"}}}

" jnurmine/Zenburn {{{
if s:bundled('Zenburn')
  if !has('win32') && !has('gui_running')
    try
      colorscheme zenburn
    catch
    endtry
  endif
endif
" }}}

" junegunn/vim-easy-align {{{
if s:bundled('vim-easy-align')
  vmap <CR> <Plug>(EasyAlign)
endif
"}}}

" kannokanno/previm {{{
if s:bundled('previm')
  autocmd MyAutoCmd FileType markdown nnoremap <silent> <buffer> <Space>p :<C-U>PrevimOpen<CR>
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

" mattn/sonictemplate-vim {{{
if s:bundled('sonictemplate-vim')
  let g:sonictemplate_vim_template_dir = s:vimfiles . '/template'
endif
" }}}

" osyo-manga/vim-anzu {{{
if s:bundled('vim-anzu')
  nmap n <Plug>(anzu-n-with-echo)
  nmap N <Plug>(anzu-N-with-echo)
  nmap * <Plug>(anzu-star-with-echo)
  nmap # <Plug>(anzu-sharp-with-echo)
endif
"}}}

" osyo-manga/vim-textobj-multiblock {{{
if s:bundled('vim-textobj-multiblock')
  let g:textobj_multiblock_blocks = [
    \   ['(', ')'],
    \   ['[', ']'],
    \   ['{', '}'],
    \   ['<', '>']
    \ ]
  "Disable default settings
  let g:textobj#multiblock#default_blocks = []
endif
"}}}

" osyo-manga/vim-textobj-multitextobj {{{
if s:bundled('vim-textobj-multitextobj')
  let g:textobj_multitextobj_textobjects_i = [
    \   '<Plug>(textobj-multiblock-i)',
    \   '<Plug>(textobj-jabraces-parens-i)',
    \   '<Plug>(textobj-jabraces-braces-i)',
    \   '<Plug>(textobj-jabraces-brackets-i)',
    \   '<Plug>(textobj-jabraces-angles-i)',
    \   '<Plug>(textobj-jabraces-double-angles-i)',
    \   '<Plug>(textobj-jabraces-kakko-i)',
    \   '<Plug>(textobj-jabraces-double-kakko-i)',
    \   '<Plug>(textobj-jabraces-yama-kakko-i)',
    \   '<Plug>(textobj-jabraces-double-yama-kakko-i)',
    \   '<Plug>(textobj-jabraces-kikkou-kakko-i)',
    \   '<Plug>(textobj-jabraces-sumi-kakko-i)'
    \ ]
  let g:textobj_multitextobj_textobjects_a = [
    \   '<Plug>(textobj-multiblock-a)',
    \   '<Plug>(textobj-jabraces-parens-a)',
    \   '<Plug>(textobj-jabraces-braces-a)',
    \   '<Plug>(textobj-jabraces-brackets-a)',
    \   '<Plug>(textobj-jabraces-angles-a)',
    \   '<Plug>(textobj-jabraces-double-angles-a)',
    \   '<Plug>(textobj-jabraces-kakko-a)',
    \   '<Plug>(textobj-jabraces-double-kakko-a)',
    \   '<Plug>(textobj-jabraces-yama-kakko-a)',
    \   '<Plug>(textobj-jabraces-double-yama-kakko-a)',
    \   '<Plug>(textobj-jabraces-kikkou-kakko-a)',
    \   '<Plug>(textobj-jabraces-sumi-kakko-a)',
    \ ]

  omap ab <Plug>(textobj-multitextobj-a)
  omap ib <Plug>(textobj-multitextobj-i)
  vmap ab <Plug>(textobj-multitextobj-a)
  vmap ib <Plug>(textobj-multitextobj-i)
endif
"}}}

" thinca/vim-quickrun {{{
if s:bundled('vim-quickrun')
  let s:bundle = neobundle#get('vim-quickrun')
  function! s:bundle.hooks.on_source(bundle) abort
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

      let g:quickrun_config['javascript.chakra'] = {
        \   'command': 'CScript',
        \   'exec': '%c //Nologo //E:\{16d51579-a30b-4c8b-a276-0ff4dc41e755\} %s',
        \   'hook/output_encode/encoding': 'cp932',
        \   'outputter/quickfix/errorformat': '%f(%l\\,\ %c)\ JavaScript\ %m'
        \ }

      let g:quickrun_config['javascript.jscript'] = {
        \   'command': 'CScript',
        \   'exec': '%c //Nologo //E:JScript %s',
        \   'hook/output_encode/encoding': 'cp932',
        \   'outputter/quickfix/errorformat': '%f(%l\\,\ %c)\ Microsoft\ JScript\ %m'
        \ }
    endif

    " Silent syntax checker
    execute 'highlight SilentSyntaxChecker gui=undercurl guisp=Red'
    let g:hier_highlight_group_qf = 'SilentSyntaxChecker'

    let s:silent_quickfix = quickrun#outputter#quickfix#new()
    function! s:silent_quickfix.finish(session) abort
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

  nnoremap <silent> <Space>r :<C-U>QuickRun<CR>

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
  function! s:my_clojure_mapping() abort
    nmap <buffer> <C-CR> <Plug>FireplacePrintip
    vmap <buffer> <C-CR> <Plug>FireplacePrint
  endfunction
  autocmd MyAutoCmd FileType clojure call <SID>my_clojure_mapping()
  autocmd MyAutoCmd FileType clojure command! -nargs=0 Austin :Piggieback (reset! cemerick.austin.repls/browser-repl-env (cemerick.austin/repl-env))
endif
"}}}

" vim-jp/vim-go-extra {{{
if s:bundled('vim-go-extra')
  autocmd MyAutoCmd BufWritePre *.go Fmt
endif
" }}}

" Pychimp/vim-sol {{{
if s:bundled('vim-sol')
  augroup solcolorscheme
    autocmd!
    autocmd ColorScheme sol highlight Comment guifg=#a0a0a0
    autocmd ColorScheme sol highlight Folded guifg=#8d8d8d
    autocmd ColorScheme sol highlight IncSearch guibg=#9999ff
    autocmd ColorScheme sol highlight MatchParen guibg=#8d8d8d
    autocmd ColorScheme sol highlight Search guibg=#ccccff
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
