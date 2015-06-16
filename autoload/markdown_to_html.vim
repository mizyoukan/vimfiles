let s:save_cpo = &cpo
set cpo&vim

let g:markdown_to_html#css_path = get(g:, 'markdown_to_html#css_path',
  \ expand('<sfile>:p:h:h') . '/resources/markdown_to_html.css')

let g:markdown_to_html#codehilite_css_class =
  \ get(g:, 'markdown_to_html#codehilite_css_class', 'highlight')

function! markdown_to_html#exec(file, line1, line2) abort
  if !has('python3')
    echohl WarningMsg
    echomsg "markdown_to_html must install python3 and library of markdown, pygments"
    echohl None
    return
  endif

  py3 << EOF
import markdown
import os.path
import vim

def markdown_to_html(line1, line2):
  css_class = vim.vars['markdown_to_html#codehilite_css_class']
  md = markdown.Markdown(
    extensions=['markdown.extensions.extra',
                'markdown.extensions.codehilite',
                'markdown.extensions.nl2br',
                'markdown.extensions.sane_lists',
                'markdown.extensions.meta'],
    extension_configs={'markdown.extensions.codehilite': {'css_class': css_class}}
  )

  body = md.convert('\n'.join(vim.current.buffer[line1-1:line2]))
  meta = getattr(md, 'Meta', {})

  html = []
  html.append("<!DOCTYPE html>")
  html.append("<html>")
  html.append("<head>")
  html.append('<meta charset="utf-8">')

  if "title" in meta:
    html.append("<title>" + meta["title"][0] + "</title>")

  css_path = vim.vars["markdown_to_html#css_path"]
  if os.path.exists(css_path):
    html.append("<style>")
    with open(css_path, 'r', encoding="utf-8") as reader:
      html.extend([x.rstrip() for x in reader])
    html.append("</style>")

  html.append("</head>")
  html.append("<body>")

  html.extend(body.split('\n'))

  html.append("</body>")
  html.append("</html>")

  return html
EOF
  let html = py3eval('markdown_to_html(' . a:line1 . ',' . a:line2 . ')')

  if a:file =~# '\v^\s*$'
    let name_tr = fnamemodify(bufname('%'), ':p:r')
    let name_e = fnamemodify(bufname('%'), ':e')
    let name = name_tr . '.' . name_e . '.html'
    let i = 1
    while filereadable(name)
      let name = name_tr . '.' . name_e . i . '.html'
      let i += 1
    endwhile

    execute 'new' name
    setlocal modifiable
    silent %delete _

    call append(0, html)
  else
    call writefile(html, a:file)
    echo 'Saved to "' . fnamemodify(a:file, ':p') . '"'
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
