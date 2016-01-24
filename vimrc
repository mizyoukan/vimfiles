" Initialize {{{

let &termencoding = &encoding
set encoding=utf-8
scriptencoding utf-8

let s:vimfiles = expand(has('win32') ? '$UserProfile/vimfiles' : '$HOME/.vim')
let s:cachedir = s:vimfiles . '/.cache'

" Popup if has already opened other Vim
silent! runtime macros/editexisting.vim

" Avoid loading menu.vim
if &guioptions !~# 'M'
  set guioptions+=M
endif

" }}}

" Plugins {{{

let s:bundledir = s:vimfiles . '/bundle'
let s:neobundledir = s:bundledir . '/neobundle.vim'

function! s:installed(bundle) abort
  if !isdirectory(s:bundledir)
    return 0
  elseif a:bundle ==# 'neobundle.vim' && isdirectory(s:neobundledir)
    return 1
  else
    return neobundle#is_installed(a:bundle)
  endif
endfunction

if !s:installed('neobundle.vim') && executable('git')
  echo 'Install NeoBundle ...'
  if !isdirectory(s:bundledir)
    call mkdir(iconv(s:bundledir, &encoding, &termencoding), 'p')
  endif
  call system('git clone https://github.com/Shougo/neobundle.vim ' . shellescape(s:neobundledir))
endif

if has('vim_starting') && isdirectory(s:neobundledir)
  let &runtimepath = &runtimepath . ',' . s:neobundledir
endif

if s:installed('neobundle.vim')
  filetype plugin indent off

  " Use shallow clone
  let g:neobundle#types#git#clone_depth = 1

  call neobundle#begin(s:bundledir)

  NeoBundleFetch 'Shougo/neobundle.vim'

  if !has('win32')
    NeoBundle 'Shougo/vimproc', {'build': 'make'}
    NeoBundle 'vim-jp/vimdoc-ja'
    set helplang=ja,en
  endif

  NeoBundle 'Shougo/neocomplete.vim', {'disabled': !has('lua'), 'vim_version' : '7.3.885'}
  NeoBundle 'Shougo/neosnippet', {'depends': ['Shougo/neocomplete.vim', 'Shougo/neosnippet-snippets']}
  NeoBundle 'Yggdroot/indentLine'
  NeoBundle 'jiangmiao/auto-pairs'
  NeoBundle 'kien/rainbow_parentheses.vim'
  NeoBundle 'mattn/emmet-vim'
  NeoBundle 'mattn/sonictemplate-vim'
  NeoBundle 'scrooloose/syntastic'
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'tpope/vim-fugitive', { 'augroup' : 'fugitive'}
  NeoBundle 'tpope/vim-surround'
  NeoBundle 'vim-jp/vital.vim'

  NeoBundleLazy 'Shougo/unite.vim', {
    \   'depends': 'Shougo/neomru.vim',
    \   'autoload': {'commands': 'Unite'}
    \ }
  NeoBundleLazy 'Shougo/vimfiler', {
    \   'depends': 'Shougo/unite.vim',
    \   'autoload': {
    \     'commands': [
    \       {'name': 'VimFiler', 'complete': 'customhist,vimfiler#complete'},
    \       'VimFiler', 'VimFilerTab', 'VimFilerBufferDir',
    \       'Edit', 'Read', 'Source', 'Write'
    \     ],
    \     'mappings': '<Plug>(vimfiler_',
    \     'explorer': 1
    \   }
    \ }
  NeoBundleLazy 'junegunn/vim-easy-align', {
    \   'autoload': {
    \     'commands': ['EasyAlign', 'LiveEasyAlign'],
    \     'mappings': '<Plug>(EasyAlign)'
    \   }
    \ }
  NeoBundleLazy 'kmnk/vim-unite-giti', {'autoload': {'unite_sources': ['giti']}}
  NeoBundleLazy 'mizyoukan/previm', {
    \   'depends': 'tyru/open-browser.vim',
    \   'autoload': {'commands': 'PrevimOpen'}
    \ }
  NeoBundleLazy 'thinca/vim-quickrun', {'autoload': {'commands': 'QuickRun'}}
  NeoBundleLazy 'thinca/vim-scouter', {'autoload': {'commands': 'Scouter'}}

  NeoBundleLazy 'myhere/vim-nodejs-complete', {'autoload': {'filetypes': 'javascript'}}
  NeoBundleLazy 'pangloss/vim-javascript', {'autoload': {'filetypes': 'javascript'}}

  NeoBundleLazy 'JulesWang/css.vim', {'autoload': {'filetypes': 'css'}}
  NeoBundleLazy 'gorodinskiy/vim-coloresque', {'autoload': {'filetypes': 'css'}}

  if isdirectory(expand('~/src/github.com/mizyoukan/nim/nim.vim'))
    call neobundle#local('~/src/github.com/mizyoukan/nim', {}, ['nim.vim'])
  endif

  NeoBundleLazy 'tpope/vim-fireplace', {'autoload': {'filetypes': 'clojure'}}
  if !has('python') || !executable('lein')
    NeoBundleDisable 'tpope/vim-fireplace'
  endif

  if executable('go')
    NeoBundleLazy 'vim-jp/vim-go-extra', {'autoload': {'filetypes': 'go'}}
    NeoBundleLazy 'nsf/gocode', {'rtp': 'vim', 'autoload': {'filetypes': 'go'}}
    call neobundle#config('gocode', {'build': {
      \ 'windows': 'go build -ldflags -H=windowsgui && move /Y gocode.exe ' . shellescape(expand('$GOPATH') . '/bin'),
      \ 'others': 'go build && mv -f gocode ' . shellescape(expand('$GOPATH') . '/bin')
      \ }})
  endif

  NeoBundle 'Pychimp/vim-sol'
  NeoBundle 'jnurmine/Zenburn'

  call neobundle#end()

  NeoBundleCheck

  if !has('vim_starting')
    call neobundle#call_hook('on_source')
  endif
endif

filetype plugin indent on

" }}}

" colorscheme {{{

if !has('win32') && !has('gui_running')
  silent! colorscheme zenburn
endif

" }}}

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
set helplang=ja,en
set hidden
set hlsearch
set ignorecase
set iminsert=0
set imsearch=0
set incsearch
set laststatus=2
set lazyredraw
set linebreak
set list
set mouse=a
set nrformats=hex
set scrolloff=5
set shiftwidth=2
set sidescroll=1
set sidescrolloff=5
set smartcase
set smartindent
set softtabstop=2
set splitright splitbelow
set synmaxcol=300
set t_Co=256
set tabstop=2
set undofile
set wildignore=.git/,.hg/,.svn/
set wildignore+=*.bmp,*.jpg,*.jpeg,*.png,*.gif
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.so,*.out,*.class,*.db
set wildignore+=*.swp,*.swo,*.swn
set wildignore+=*.DS_Store
set wildmenu
set nowrap

if has('win32') && !has('gui_running')
  set listchars=tab:^_,trail:_,extends:>,precedes:<
  let &showbreak = '> '
else
  set listchars=tab:▸-,trail:_,extends:￫,precedes:￩
  let &showbreak = '↳ '
endif

if has('patch-7.4.338')
  set breakindent
  augroup breakindent
    autocmd!
    autocmd BufEnter * setlocal breakindentopt=min:20,shift:0
  augroup END
endif

set fileencodings=utf-8,cp932,euc-jp
if has('win32')
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif

function! s:letandmkdir(var, path) abort
  try
    if !isdirectory(a:path)
      call mkdir(a:path, 'p')
    endif
    execute printf('let %s = a:path', a:var)
  catch
    echohl WarningMsg | echomsg 'Failed to mkdir "' . a:path '"' | echohl None
  endtry
endfunction

call s:letandmkdir('&backupdir', s:vimfiles . '/.backup')
call s:letandmkdir('&directory', s:vimfiles . '/.swap')
call s:letandmkdir('&undodir', s:vimfiles . '/.undo')

" Status line {{{

let g:mystatusline_ftmap = {
  \   'clojure.clojurescript': 'clojurescript',
  \   'javascript.chakra': 'chakra',
  \   'javascript.jscript': 'jscript'
  \ }

function! MyStatusLine(isactive) abort
  let line = '[%n]%{winnr("$")>1?"[".winnr()."/".winnr("$")."]":""}%t %m%r%h%w%<'

  if a:isactive
    let activebuf = bufnr('%')
    let bufs = filter(range(1, bufnr('$')),
      \ 'buflisted(v:val) && v:val != activebuf && getbufvar(v:val, "&modifiable")')
    if len(bufs) > 0
      let line .= '[' . join(map(bufs, 'v:val . ":" . ' .
        \ 'fnamemodify(bufname(v:val), ":t") . ' .
        \ '(getbufvar(v:val, "&modified") ? "+" : "")'), '|') . ']'
    endif
  endif
  if has('win32') && !has('gui_running')
    let line .= '>%=<'
  else
    let line .= '»%=«'
  endif

  let line .= '%{&ft==#"" ? "" : "[".get(g:mystatusline_ftmap,&ft,&ft)."]"}'
  let line .= '[%{&fenc}/%{&ff}] %p%% %l:%c'

  return line
endfunction

function! s:refresh_statusline() abort
  let activewin = winnr()
  for n in range(1, winnr('$'))
    call setwinvar(n, '&statusline', '%!MyStatusLine(' . (n == activewin) . ')')
  endfor
endfunction

augroup statusline
  autocmd!
  autocmd BufEnter,WinEnter * call <SID>refresh_statusline()
augroup END

" }}}

" Folding {{{

function! MyFoldText() abort
  let left = getline(v:foldstart) . ' ...'
  let foldedlinecount = v:foldend - v:foldstart
  let right = '[' . foldedlinecount . '] '
  let numbercolwidth = &foldcolumn + (&number || &relativenumber) * (&numberwidth + 1)
  let linewidth = winwidth(0) - numbercolwidth
  let spacecount = linewidth - strdisplaywidth(left) - strwidth(right)
  return left . repeat(' ', spacecount) . right
endfunction

let &fillchars = 'vert: ,diff: '
set foldlevel=99
set foldlevelstart=99
set foldmethod=marker
set foldopen&
set foldopen-=block
set foldtext=MyFoldText()

" }}}

let g:vim_indent_cont = 2

let g:netrw_banner = 0

" }}}

" Commands and functions {{{

" Delete current buffer without closing window
function! s:bdelete_currbuf(bang) abort
  let bn = bufnr('%')
  bprevious
  try
    execute 'bdelete' . a:bang bn
  catch /E89:/
    execute 'buffer' bn
    echoerr v:exception
  endtry
endfunction
command! -nargs=0 -bang KillCurrentBuffer call <SID>bdelete_currbuf('<bang>')

function! s:foldl(op, state, list) abort
  return eval(join(insert(a:list, a:state), a:op))
endfunction

" Wipeout hidden and nomodified buffers
function! s:ninja_bwipeout(bang) abort
  let leave_bufnrs = s:foldl('+', [], map(range(1, tabpagenr('$')), 'tabpagebuflist(v:val)'))
  let filter_pred = 'index(leave_bufnrs, v:val)==-1 && bufexists(v:val)'
  let filter_pred .= a:bang !=# '!' ? ' && !getbufvar(v:val, "&modified")' : ''
  let bw_bufnrs = filter(range(1, bufnr('$')), filter_pred)
  for bufnr in bw_bufnrs
    execute 'bwipeout' . a:bang bufnr
  endfor
endfunction
command! -nargs=0 -bang NinjaBwipeout call <SID>ninja_bwipeout('<bang>')

" Remove line end space
function! s:remove_trailing_spaces() abort
  let cursor = getpos('.')
  execute '%s/\s\+$//ge'
  call setpos('.', cursor)
endfunction
command! -nargs=0 RemoveTrailingSpaces call <SID>remove_trailing_spaces()

if has('gui_running')
  command! -bang MyScouter Scouter<bang> $MYVIMRC $MYGVIMRC
else
  command! -bang MyScouter Scouter<bang> $MYVIMRC
endif

" Convert Markdown -> HTML <autoload/markdown_to_html.vim>
command! -nargs=? -range=% MarkdownToHTML call markdown_to_html#exec(<q-args>, <line1>, <line2>)

" Register expenses <autoload/expenses_register.vim>
command! -nargs=0 ExpensesRegister call expenses_register#exec()

" }}}

" Key mappings {{{

" Create empty map
noremap <Space> <Nop>

" Replace key because hard to type
noremap <Space>h ^
noremap <Space>l $
noremap <Space>j %

nnoremap Y y$

" Highlight off
nnoremap <silent> <Esc><Esc> :nohlsearch<CR><Esc>
nnoremap <silent> <C-L> :<C-U>nohlsearch<CR><C-L>

" Select command history
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Toggle folding
noremap <Space>a za
" Close folding without current cursor
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

" Key repeat hack for resizing splits
nmap <C-W>+ <C-W>+<SID>ws
nmap <C-W>- <C-W>-<SID>ws
nmap <C-W>< <C-W><<SID>ws
nmap <C>W>> <C>W>><SID>ws
nnoremap <script> <SID>ws+ <C-W>+<SID>ws
nnoremap <script> <SID>ws- <C-W>-<SID>ws
nnoremap <script> <SID>ws< <C-W><<SID>ws
nnoremap <script> <SID>ws> <C>W>><SID>ws
nmap <SID>ws <Nop>

" Edit/source vimrc
nnoremap <Space>ev :<C-U>edit $MYVIMRC<CR>
nnoremap <Space>sv :<C-U>split $MYVIMRC<CR>
if has('gui_running')
  nnoremap <Space>vv :<C-U>source $MYVIMRC \| source $MYGVIMRC<CR>
  nnoremap <Space>eg :<C-U>edit $MYGVIMRC<CR>
  nnoremap <Space>sg :<C-U>split $MYGVIMRC<CR>
  nnoremap <Space>vg :<C-U>source $MYGVIMRC<CR>
else
  nnoremap <Space>vv :<C-U>source $MYVIMRC<CR>
endif

" Edit/source vimrc_local.vim
execute 'nnoremap <Space>el :<C-U>edit' s:vimfiles . '/vimrc_local.vim<CR>'
execute 'nnoremap <Space>sl :<C-U>split' s:vimfiles . '/vimrc_local.vim<CR>'
execute 'nnoremap <Space>vl :<C-U>source' s:vimfiles . '/vimrc_local.vim<CR>'

" My memo <autoload/mymemo.vim> <autoload/unite/sources/mymemo.vim>
nnoremap mc :<C-U>MemoNew<CR>
nnoremap ma :<C-U>Unite mymemo<CR>
" autocmd MyAutoCmd BufWritePre *.md call mymemo#update_date()

nnoremap <Space>gd :<C-U>Gdiff<CR>
nnoremap <Space>gs :<C-U>Gstatus<CR>

nnoremap <Space>u :<C-U>Unite buffer bookmark file_mru directory_mru<CR>
nnoremap <Space>/ :<C-U>Unite line<CR>

nnoremap <Space>gb :<C-U>Glcd \| Unite giti/branch<CR>
nnoremap <Space>gf :<C-U>Glcd \| Unite file_rec/git<CR>
nnoremap <Space>gg :<C-U>Glcd \| Unite giti<CR>
nnoremap <Space>gl :<C-U>Glcd \| Unite giti/log -no-start-insert<CR>

nnoremap <Space>f :<C-U>VimFilerBufferDir -buffer-name=explorer -explorer -split -simple -toggle -winwidth=35 -no-quit<CR>

nnoremap <Space>r :<C-U>QuickRun<CR>

vmap <CR> <Plug>(EasyAlign)

if s:installed('neocomplete.vim')
  " Close popup and delete backword char
  inoremap <expr> <C-H> pumvisible() ? neocomplete#smart_close_popup() . '<C-H>' : AutoPairsDelete()
  inoremap <expr> <BS>  pumvisible() ? neocomplete#smart_close_popup() . '<C-H>' : AutoPairsDelete()
endif

" }}}

" Events {{{

function! s:ftdetect_jscript() abort
  if getline(1) =~? '^@if\s*(0)\s*==\s*(0)'
    for i in range(2, 5)
      let line = getline(i)
      if line =~? '^CScript.\+//E:{16d51579-a30b-4c8b-a276-0ff4dc41e755}'
        setlocal filetype=javascript.chakra
        return
      elseif line =~? '^CScript.\+//E:JScript'
        setlocal filetype=javascript.jscript
        return
      endif
    endfor
  endif
endfunction

augroup bufinit
  autocmd!

  autocmd BufNewFile,BufRead * setlocal formatoptions=tcrqjM

  autocmd BufNewFile,BufRead *.bat call <SID>ftdetect_jscript()

  autocmd BufNewFile,BufRead *.{md,mkd,markdown} setlocal filetype=markdown
  autocmd BufNewFile,BufRead *.{cljs,cljx} setlocal filetype=clojure.clojurescript
  autocmd BufNewFile,BufRead *.edn setlocal filetype=clojure
  autocmd BufNewFile,BufRead *.vue setfiletype html
augroup END

augroup filetypes
  autocmd!

  autocmd FileType vim nnoremap <buffer> <Space>v. :<C-U>source %<CR>

  autocmd FileType netrw nmap <buffer> q :<C-U>quit<CR>
  autocmd FileType netrw nunmap <buffer> qF
  autocmd FileType netrw nunmap <buffer> qf
  autocmd FileType netrw nunmap <buffer> qb

  autocmd FileType unite imap <buffer> <expr> <C-S> unite#do_action('split')
  autocmd FileType unite imap <buffer> <C-J> <Plug>(unite_select_next_line)
  autocmd FileType unite imap <buffer> <C-K> <Plug>(unite_select_previous_line)
  autocmd FileType unite imap <buffer> <C-B> <Left>
  autocmd FileType unite imap <buffer> <C-F> <Right>
  autocmd FileType unite imap <buffer> <C-A> <Home>
  autocmd FileType unite imap <buffer> <C-E> <End>
  autocmd FileType unite imap <buffer> <C-D> <Del>

  autocmd FileType qf nmap <buffer> q :<C-U>bdelete<CR>
  autocmd FileType qf nnoremap <buffer> p <CR>zz<C-W>p

  autocmd FileType help nmap <buffer> q :<C-U>quit<CR>
  autocmd FileType help setlocal nolist

  autocmd FileType neosnippet setlocal noexpandtab

  autocmd FileType python setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
  autocmd FileType python inoremap <buffer> # X#

  autocmd FileType go setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
  autocmd FileType go nnoremap <buffer> K :<C-U>Godoc<CR>

  autocmd FileType markdown setlocal shiftwidth=4 softtabstop=4 tabstop=4
  autocmd FileType markdown setlocal breakat=
  autocmd FileType markdown nnoremap <buffer> <Space>p :<C-U>PrevimOpen<CR>

  autocmd FileType clojure let b:AutoPairs = {'(':')', '[':']', '{':'}', '"':'"'}
augroup END

" }}}

" Plugin settings {{{

" Shougo/neocomplete.vim
let g:neocomplete#data_directory = s:cachedir . '/neocomplete'
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_ignore_case = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#force_overwrite_completefunc = 1
let g:neocomplete#max_list = 20

if s:installed('neocomplete.vim')
  let s:bundle = neobundle#get('neocomplete.vim')
  function! s:bundle.hooks.on_source(bundle) abort
    let g:neocomplete#keyword_patterns = get(g:, 'neodomplete#keywork_patterns', {})
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'
  endfunction
  unlet s:bundle
endif

" Shougo/neosnippet
let g:neosnippet#disable_runtime_snippets = {'_': 1}
let g:neosnippet#enable_snipmate_compatibility = 1

let g:neosnippet#data_directory = s:cachedir . '/neosnippet'
let g:neosnippet#snippets_directory = [
  \   s:bundledir . '/neosnippet-snippets/neosnippets',
  \   s:vimfiles . '/snippets'
  \ ]

if s:installed('neosnippet')
  if has('conceal')
    set conceallevel=2 concealcursor=i
  endif

  imap <C-K> <Plug>(neosnippet_expand_or_jump)
  smap <C-K> <Plug>(neosnippet_expand_or_jump)

  imap <expr> <TAB> neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : pumvisible() ? '<C-N>' : '<TAB>'
  smap <expr> <TAB> neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '<TAB>'

  " Delete merkers when InsertLeave
  augroup neosnippet_clear_markers
    autocmd!
    autocmd InsertLeave * NeoSnippetClearMarkers
  augroup END
endif

" Shougo/unite.vim
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

if s:installed('unite.vim')
  let s:bundle = neobundle#get('unite.vim')
  function! s:bundle.hooks.on_source(bundle) abort
    call unite#custom#source('mymemo', 'sorters', ['sorter_ftime', 'sorter_reverse'])
  endfunction
  unlet s:bundle
endif

" Shougo/vimfiler
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_data_directory = s:cachedir . '/vimfiler'
let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_tree_indentation = 2
let g:vimfiler_tree_leaf_icon = ' '

" jiangmiao/auto-pairs
" For avoiding conflict with neocomplete.vim
let g:AutoPairsMapBS = 0

if s:installed('auto-pairs')
  if has('unix') && !has('gui_running')
    set <M-e>=<Esc>e
    imap <Esc>e <M-e>
    set <M-n>=<Esc>n
    imap <Esc>n <M-n>
  endif
endif

" kien/rainbow_parentheses.vim
if s:installed('rainbow_parentheses.vim')
  augroup parentheses
    autocmd!
    autocmd VimEnter * RainbowParenthesesToggle
    autocmd Syntax * RainbowParenthesesLoadRound
    autocmd Syntax * RainbowParenthesesLoadSquare
    autocmd Syntax * RainbowParenthesesLoadBraces
  augroup END
endif

" mattn/sonictemplate-vim
let g:sonictemplate_vim_template_dir = s:vimfiles . '/template'

" scrooloose/syntastic
let g:syntastic_auto_loc_list = 1

" tomtom/tcomment_vim
let g:tcomment_types = get(g:, 'tcomment_types', {})
let g:tcomment_types['markdown'] = '<!-- %s -->'
let tcomment#ignore_comment_def = ['clojurescript']

" thinca/vim-quickrun
if s:installed('vim-quickrun')
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
      let g:quickrun_config.dosbatch = {
        \   'runner': 'system',
        \   'hook/output_encode/encoding': 'cp932'
        \ }

      let g:quickrun_config.python = {
        \   'hook/output_encode/encoding': 'cp932'
        \ }

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

      let g:quickrun_config.nim = {
        \   'command': 'nim',
        \   'cmdopt': 'compile --run --verbosity:0',
        \   'hook/sweep/files': ['%S:p:r.exe'],
        \   'tempfile': '%{substitute(tempname(), ''\(\d\+\)$'', ''nim\1.nim'', '''')}'
        \ }
    endif
  endfunction
  unlet s:bundle
endif

" nim.vim
let g:nim#system_function = 'vimproc#system'

" previm
let g:previm_parse_yaml_format_matter = 1

" }}}

" Local settings {{{

if filereadable(s:vimfiles . '/vimrc_local.vim')
  execute 'source' s:vimfiles . '/vimrc_local.vim'
endif

" }}}

