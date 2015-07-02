let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#mymemo#define() abort
  return s:source
endfunction

let s:source = {
  \   'name': 'mymemo',
  \   'description': 'candidates from my memo',
  \   'default_kind': 'file'
  \ }

function! s:source.gather_candidates(args, context) abort
  if !isdirectory(g:mymemo#root) | return [] | endif

  let l:file_pattern = fnamemodify(g:mymemo#root, ':p') . '/**/*.' .
    \ fnamemodify(g:mymemo#filename, ':e')

  return map(split(glob(l:file_pattern), "\n"), '{
    \   "word": s:candidate_word(v:val),
    \   "action__path": v:val,
    \   "action__directory": fnamemodify(v:val, ":p:h")
    \ }')
endfunction

function! s:candidate_word(file) abort
  let l:head = readfile(a:file, '', len(g:mymemo#template))
  let l:dict = {}
  call map(map(filter(copy(l:head),
    \ 'match(v:val, "^\\w\\+:") == 0'),
    \ 'split(v:val, ":")'),
    \ 'extend(l:dict, {s:strip(v:val[0]): s:strip(join(v:val[1:], ":"))})')
  let l:word = fnamemodify(a:file, ':t') . '|'
  if has_key(l:dict, 'title')
    if has_key(l:dict, 'tags') && len(l:dict['tags']) > 0
      let l:word .= l:dict['tags'] . ' '
    endif
    let l:word .= l:dict['title']
  else
    let l:word .= substitute(get(filter(l:head, 'v:val!=#"^\\s*$"'),
      \ 0, ''), '^#\+\s*', '', '')
  endif
  return l:word
endfunction

function! s:strip(text) abort
  return substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
