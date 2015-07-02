if exists('g:loaded_mymemo')
  finish
endif
let g:loaded_mymemo = 1

let s:save_cpo = &cpo
set cpo&vim

let g:mymemo#root = get(g:, 'mymemo#root', expand('~/memo'))
let g:mymemo#filename = get(g:, 'mymemo#filename', '%Y/%m/%Y-%m-%d-%H%M%S.md')
let g:mymemo#template = get(g:, 'mymemo#template', map([
  \   '---',
  \   'layout: post',
  \   'title: <_1:title_>',
  \   'date: <_2:date_>',
  \   'tags: [<_3_>]',
  \   '---',
  \   '<_0_>'
  \ ], 'substitute(v:val, "_", "`", "g")'))

command! -nargs=? MemoNew call mymemo#new(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
