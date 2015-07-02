let s:save_cpo = &cpo
set cpo&vim

let g:markdown_to_html#css_path = get(g:, 'markdown_to_html#css_path',
  \ expand('<sfile>:p:h:h') . '/resources/markdown_to_html.css')

let g:markdown_to_html#codehilite_css_class =
  \ get(g:, 'markdown_to_html#codehilite_css_class', 'highlight')

let g:markdown_to_html#converts_image_to_base64 =
  \ get(g:, 'markdown_to_html#converts_image_to_base64', 1)

let g:markdown_to_html#trunc_whitespace_in_jp_text =
  \ get(g:, 'markdown_to_html#trunc_whitespace_in_jp_text', 1)

function! markdown_to_html#exec(file, line1, line2) abort
  if !has('python3')
    echohl WarningMsg
    echomsg 'markdown_to_html must install python3 and library of markdown, pygments'
    echohl None
    return
  endif

  python3 << EOF
import base64
from functools import reduce
from html.parser import HTMLParser
import io
import markdown
import mimetypes
import os.path
import re
import vim

class HTMLBase64EncodeParser(HTMLParser):
  def __init__(self, writer, trunc_whitespace_in_jp_text=0):
    HTMLParser.__init__(self)
    self.writer = writer
    self.in_pre = False
    if trunc_whitespace_in_jp_text > 0:
      self.trunc_whitespace_in_jp_text = self._trunc_whitespace_in_jp_text
    else:
      self.trunc_whitespace_in_jp_text = lambda x: x

  def handle_starttag(self, tag, attrs):
    self.writer.write("<" + tag)
    self._write_attrs(tag, attrs)
    self.writer.write(">")
    if tag == 'pre':
      self.in_pre = True

  def handle_endtag(self, tag):
    self.writer.write("</" + tag + ">")
    if tag == 'pre':
      self.in_pre = False

  def handle_startendtag(self, tag, attrs):
    self.writer.write("<" + tag)
    self._write_attrs(tag, attrs)
    self.writer.write(" />")

  def handle_data(self, data):
    data = self.trunc_whitespace_in_jp_text(data)
    self.writer.write(data)

  def handle_entityref(self, name):
    self.writer.write("&" + name + ";")

  def handle_charref(self, name):
    self.writer.write("&#" + name + ";")

  def _write_attrs(self, tag, attrs):
    for [k, v] in attrs:
      if tag == 'img' and k == 'src' and os.path.isfile(v):
        with open(v, 'rb') as f:
          b64 = base64.b64encode(f.read())
          mime, _ = mimetypes.guess_type(v)
          v = "data:{0};base64,{1}".format(mime, b64.decode('utf-8'))
      self.writer.write(' {0}="{1}"'.format(k, v))

  def _trunc_whitespace_in_jp_text(self, data):
    if self.in_pre:
      return data
    lines = re.split(r'\r\n|\r|\n', data)
    def f(a, b):
      a = a.rstrip()
      b = b.lstrip()
      if re.search(r'[\x01-\x7E]$', a) != None and re.search(r'^[\x01-\x7E]', b) != None:
        return a + ' ' + b
      return a + b
    return reduce(f, lines)

def markdown_to_html(line1, line2):
  css_class = vim.vars['markdown_to_html#codehilite_css_class']
  md = markdown.Markdown(
    extensions=['markdown.extensions.extra',
                'markdown.extensions.codehilite',
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
      style = [x.rstrip() for x in reader]
      if len(style) > 0 and style[0].find("@charset") == 0:
        style = style[1:]
      html.extend(style)
    html.append("</style>")

  html.append("</head>")
  html.append("<body>")

  converts_image_to_base64 = vim.vars["markdown_to_html#converts_image_to_base64"]
  trunc_whitespace_in_jp_text = vim.vars['markdown_to_html#trunc_whitespace_in_jp_text']
  if converts_image_to_base64 > 0:
    with io.StringIO() as writer:
      parser = HTMLBase64EncodeParser(writer, trunc_whitespace_in_jp_text)
      parser.feed(body)
      html.extend(writer.getvalue().split('\n'))
  else:
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
