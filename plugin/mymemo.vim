if exists('g:loaded_mymemo')
  finish
endif
let g:loaded_mymemo = 1

let s:save_cpo = &cpo
set cpo&vim

let g:mymemo_root = get(g:, 'mymemo_root', expand(has('win32')? '$USERPROFILE' : '$HOME') . '/memo')
let g:mymemo_filename = get(g:, 'mymemo_filename', '/%Y/%m/%Y-%m-%d-%H%M%S.md')
let g:mymemo_template = get(g:, 'mymemo_template', map([
  \   '---',
  \   'title: <_1:title_>',
  \   'date: <_2:date_>',
  \   'tags: [<_3_>]',
  \   '---',
  \   '<_0_>'
  \ ], 'substitute(v:val, "_", "`", "g")'))

command! -nargs=? MemoNew call mymemo#new(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
