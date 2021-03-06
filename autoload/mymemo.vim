let s:save_cpo = &cpo
set cpo&vim

function! mymemo#new(title) abort
  if !isdirectory(g:mymemo#root) | return | endif
  if len(g:mymemo#filename) == 0 | return | endif

  let l:time = localtime()

  let l:file = fnamemodify(g:mymemo#root, ':p') . strftime(g:mymemo#filename, l:time)
  let l:dir = fnamemodify(l:file, ':p:h')
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif

  let l:cmd = getbufvar('%', '&modified') ? 'split' : 'edit'
  execute l:cmd l:file

  let l:items = {
    \   'title': a:title,
    \   'date': strftime('%Y-%m-%d %H:%M:%S', l:time)
    \ }
  call append(0, s:apply_template(g:mymemo#template, l:items))

  let l:title_rows = filter(map(copy(g:mymemo#template),
    \ 'v:val =~# "title:\\s*" ? v:key+1 : 0'), 'v:val')
  if len(l:title_rows) > 0
    call cursor(l:title_rows[0], 1)
    startinsert!
  endif
endfunction

function! mymemo#update_date() abort
  if getline(1) !=# '---' | return | endif
  for l:i in range(2, 10)
    let l:line = getline(l:i)
    if l:line ==# '---'
      return
    elseif l:line =~# '^date:'
      call setline(l:i, 'date: ' . strftime('%Y-%m-%d %H:%M:%S', localtime()))
      return
    endif
  endfor
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
