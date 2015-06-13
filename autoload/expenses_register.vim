scriptencoding utf-8

let s:V = vital#of('vital')
let s:L = s:V.import('Data.List')
let s:S = s:V.import('Data.String')
let s:D = s:V.import('DateTime')

let s:file_format = get(g:, 'expenses_register#file_format', 'tsv')
let s:file_save_path = get(g:, 'expenses_register#file_save_path', expand('~/expenses.') . s:file_format)
let s:format_date_str = get(g:, 'expenses_register#format_date', '%Y-%m-%d')

" [[label, type, required, use history to candidate]]
let s:items = get(g:, 'expenses_register#items', [
  \   ["日付",   'date',   1, 0],
  \   ["支出額", 'number', 1, 0],
  \   ["タグ",   'string', 0, 1],
  \   ["メモ",   'string', 0, 1]
  \ ])

let s:candidates_default = get(g:, 'expenses_register#candidates_default', {
  \   'タグ': ["食費", "書籍", "光熱費", "交通費"]
  \ })

let s:candidates = {}

function! expenses_register#exec() abort
  call s:load_candidates()

  let nr = bufwinnr('^expenses_reg$')
  if nr == -1
    botright split expenses_reg
    execute '2 wincmd _'

    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nomodified
    setlocal nonumber
    setlocal norelativenumber
    setlocal noswapfile
    setlocal filetype=expenses_register
    setlocal omnifunc=expenses_register#complete
    let items = map(deepcopy(s:items), 'v:val[0]')
    if len(items) > 0
      let items[0] = '[' . items[0] . ']'
    endif
    call setbufvar('%', '&statusline', join(items, ' | '))

    augroup ExpensesRegister
      nnoremap <buffer> <silent> q :bdelete!<CR>
      nmap <buffer> <silent> <CR> <Plug>(expenses_register_register)
      imap <buffer> <silent> <C-CR> <Esc><Plug>(expenses_register_register)
      nmap <buffer> <silent> <Tab> <Plug>(expenses_register_next_select)
      imap <buffer> <silent> <Tab> <Esc><Plug>(expenses_register_next_select)a
      nmap <buffer> <silent> <S-Tab> <Plug>(expenses_register_prev_select)
      imap <buffer> <silent> <S-Tab> <Esc><Plug>(expenses_register_prev_select)a
    augroup END
  else
    execute nr . 'wincmd w'
  endif

  setlocal modifiable
  silent %delete _

  startinsert!
endfunction

function! expenses_register#register() abort
  let ci = s:get_cursor_index()
  call s:format(ci)
  call s:set_cursor(ci)
  let text = getline(1)
  let values = map(split(text, '|'), 's:S.trim(v:val)')
  let error_messages = s:validate(values)
  if len(error_messages) > 0
    echohl WarningMsg | echo "Save error: " . error_messages[0] | echohl None
    return
  endif
  if s:file_format ==? 'csv'
    let text = join(values, ',')
  else
    let text = join(values, "\t")
  endif
  call writefile([text], s:file_save_path, 'a')
  bdelete!
  echo "Saved new expenses."
endfunction

function! expenses_register#next_select() abort
  let ci = min([s:get_cursor_index()+1, len(s:items)-1])
  call s:format(ci)
  call s:set_cursor(ci)
endfunction

function! expenses_register#prev_select() abort
  let ci = max([0, s:get_cursor_index()-1])
  call s:format(ci)
  call s:set_cursor(ci)
endfunction

function! s:validate(values) abort
  let error_messages = []
  let values = extend(a:values, repeat([""], len(s:items)-len(a:values)))
  for [item, value] in s:L.zip(s:items, values)
    let [name, type, required] = item[:2]
    if required && value ==# ""
      call add(error_messages, name . " requires value")
    elseif type ==# 'date'
      if s:format_date(value, s:format_date_str) ==# ""
        call add(error_messages, name . " invalid format")
      endif
    elseif type ==# 'number'
      if value !~# '^\d\+$'
        call add(error_messages, name . " invalid format")
      endif
    endif
  endfor
  return error_messages
endfunction

function! s:format(cursor_index) abort
  let labels = map(deepcopy(s:items), 'v:val[0]')
  let values = map(split(getline(1), '|'), 's:S.trim(v:val)')

  " ラベル数よりも項目が多い場合は末尾項目に結合
  if len(values) > len(labels)
    let values[len(labels)-2] = join(values[len(labels)-2 :])
  endif

  " カーソル位置よりも項目数が少ない場合は項目を追加
  if len(values) < a:cursor_index+1 && len(values) < len(labels)
    call extend(values, repeat([''], a:cursor_index+1 - len(values)))
  endif

  " カーソル位置のラベル両端に[]を付加
  let labels[a:cursor_index] = '[' . labels[a:cursor_index] . ']'

  " 各項目をフォーマット
  for i in range(len(values))
    let type = s:items[i][1]
    let value = values[i]
    if type ==# 'date'
      if value !=# ''
        let value = s:format_date(value, s:format_date_str)
        if value !=# ''
          let values[i] = value
        endif
      endif
    endif
  endfor

  " 各項目を空白でパディング (末尾項目は除外)
  for i in range(len(values)-1)
    let [label, type] = s:items[i][:1]
    let value = values[i]
    let width = max([s:S.wcswidth(label), s:S.wcswidth(value)])
    let label = s:S.pad_right(label, width)
    if value ==# ''
      let value = repeat(' ', width)
    elseif type ==# 'number'
      let value = s:S.pad_left(value, width)
    else
      let value = s:S.pad_right(value, width)
    endif
    let labels[i] = label
    let values[i] = value
  endfor

  let line = join(values, ' | ')

  call setline(1, line)
  call setbufvar('%', '&statusline', s:S.trim(join(labels, ' | ')))
  silent! 2delete
endfunction

function! s:get_cursor_index() abort
  let col = col('.')
  if col <= 1
    return 0
  endif
  return len(substitute(getline('.')[: col-2], '[^|]', '', 'g'))
endfunction

function! s:set_cursor(index) abort
  let inc = a:index+1
  let values = split(getline('.'), '|')
  if inc >= len(values)
    normal $
  else
    let action = 'normal 0' . inc . 't|'
    if values[a:index] =~# '^\s*$'
      let action .= 'h'
    else
      let action .= 'ge'
    endif
    execute action
  endif
endfunction

function! s:format_date(string, format) abort
  let pattern_formats = [
    \   ['^\d\{4}-\d\{1,2}-\d\{1,2}$', '%Y-%m-%d', ''],
    \   ['^\d\{4}/\d\{1,2}/\d\{1,2}$', '%Y/%m/%d', ''],
    \   ['^\d\{1,2}/\d\{1,2}$',        '%Y/%m/%d', strftime('%Y', localtime()) . '/'],
    \ ]
  for [pattern, format, prefix] in pattern_formats
    if a:string =~# pattern
      return s:D.from_format(prefix . a:string, format).format(a:format)
    endif
  endfor
  return ""
endfunction

function! s:load_candidates() abort
  for item in s:items
    if item[3]
      let s:candidates[item[0]] = []
    endif
  endfor
  if filereadable(s:file_save_path)
    for line in reverse(readfile(s:file_save_path))
      if s:file_format ==? 'csv'
        let words = split(line, ',')
      else
        let words = split(line, "\t")
      endif
      for [i, item] in s:L.zip(range(len(words)), s:items)
        if len(item) >= 4 && item[3]
          call add(s:candidates[item[0]], words[i])
        endif
      endfor
    endfor
  endif
  for item in s:items
    if has_key(s:candidates_default, item[0])
      call extend(s:candidates[item[0]], s:candidates_default[item[0]])
    endif
  endfor
endfunction

function! s:day_count(year, month) abort
  if a:month < 1 || 12 < a:month
    return 0
  endif
  let days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  if a:month == 2
    let days[1] += !((a:year % 4) && !(a:year % 100) || (a:year % 400))
  endif
  return days[a:month-1]
endfunction

function! expenses_register#complete(findstart, base) abort
  let ci = min([s:get_cursor_index(), len(s:items)-1])
  if a:findstart
    if !s:items[ci][3] && s:items[ci][1] !~# 'date'
      return -1
    endif
    let line = getline('.')
    let start = 0
    if ci == 0
      let start = matchend(line, '\v^ *')
    else
      let start = matchend(line, '\v\| *', strridx(line[: col('.')], '|'))
    endif
    return start
  else
    if s:items[ci][3]
      return filter(copy(s:candidates[s:items[ci][0]]), 'v:val =~? "^" . a:base')
    elseif s:items[ci][1] =~# 'date'
      " 日付補完
      let now = localtime()
      if a:base ==# ''
        " 入力がない場合、直近10日
        let res = []
        for i in reverse(range(10))
          let t = now - i*60*60*24
          call add(res, {
            \   'word': strftime(s:format_date_str, t),
            \   'menu': '(' . strftime('%a', t) . ')'
            \ })
        endfor
        return res
      elseif a:base =~# '\v^(1[0-2]|0?[1-9])(/\d?)?$'
        " m/dの場合の補完
        let year = strftime('%Y', now)
        let month = matchstr(a:base, '\v^\d+\ze/?')
        let day = matchstr(a:base, '\v/\zs\d+$')
        let res = []
        for i in range(s:day_count(year-0, month-0))
          let t = s:D.from_date(year-0, month-0, i+1)
          let s = t.format('%m/%d')
          if month !~# '^0'
            let s = substitute(s, '^0', '', '')
            if day ==# ''
              let s = substitute(s, '/\zs0', '', '')
            endif
          endif
          if day !=# ''
            if day !~# '^0'
              let s = substitute(s, '/\zs0', '', '')
            endif
            if s !~# printf('^%s/%s', month, day)
              continue
            endif
          endif
          call add(res, {
            \   'word': s,
            \   'menu': t.format(s:format_date_str . ' (%a)')
            \ })
        endfor
        return res
      endif
      return []
    else
      return []
    endif
  endif
endfunction

nnoremap <silent> <Plug>(expenses_register_register) :<C-U>call expenses_register#register()<CR>
nnoremap <silent> <Plug>(expenses_register_next_select) :<C-U>call expenses_register#next_select()<CR>
nnoremap <silent> <Plug>(expenses_register_prev_select) :<C-U>call expenses_register#prev_select()<CR>
