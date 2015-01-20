let s:save_cpo = &cpo
set cpo&vim

function! mymemo#new(title) abort
  if !isdirectory(g:mymemo_root) | return | endif
  if len(g:mymemo_filename) == 0 | return | endif

  let l:time = localtime()

  let l:file = fnamemodify(g:mymemo_root, ':p') . strftime(g:mymemo_filename, l:time)
  let l:dir = fnamemodify(l:file, ':p:h')
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif

  let l:cmd = getbufvar('%', '&modified') ? 'split' : 'edit'
  execute l:cmd l:file

  let l:items = {
    \   'title': a:title,
    \   'date': strftime('%Y-%m-%d %H:%M', l:time)
    \ }
  call append(0, s:apply_template(g:mymemo_template, l:items))

  let l:title_rows = filter(map(copy(g:mymemo_template),
    \ 'v:val =~# "title:\\s*" ? v:key+1 : 0'), 'v:val')
  if len(l:title_rows) > 0
    call setpos('.', [0, l:title_rows[0], 1, 0])
    startinsert!
  endif
endfunction

function! s:apply_template(template, items) abort
  let l:mx = '<`\d:\(\w\+\)`>'
  return map(copy(a:template), '
    \   substitute(v:val, l:mx,
    \     "\\=has_key(a:items, submatch(1)) ? a:items[submatch(1)] : submatch(0)", "g")
    \ ')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
