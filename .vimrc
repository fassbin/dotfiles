"****************************************************************************
" Initialize: {{{1
"****************************************************************************
scriptencoding utf-8
set nocompatible

if v:servername == 'test'
  source $HOME . '/.vimrc-test'
  finish
endif

let s:is_win = has('win32') || has('win64')

" コンソールでは$MYGVIMRCに値がセットされていないのでセットする
if !exists($MYGVIMRC)
  let $MYGVIMRC = $HOME."/.gvimrc"
endif

if s:is_win
  set shellslash
endif

" User Runtime Path
if isdirectory($HOME . '/.vim')
  let $MY_VIMRUNTIME = $HOME . '/.vim'
elseif isdirectory($VIM . '/.vim')
  let $MY_VIMRUNTIME = $VIM . '/.vim'
else
  let $MY_VIMRUNTIME = $VIM . '/vimfiles'
endif

" Vim Tmp Path
if isdirectory($HOME . '/var/.vim_tmp')
  let $MY_VIMTMP = $HOME . '/var/.vim_tmp'
else
  let $MY_VIMTMP = $VIM . '/.vim_tmp'
endif

" tool path
if s:is_win
  "let $MY_TOOLS = fnamemodify($VIM, ":s?bin\\\\vim?local?")
  let $MY_TOOLS = fnamemodify(expand('$VIM'), ":s?bin/vim?local?")
endif

if s:is_win
  let &runtimepath = join([expand($MY_VIMRUNTIME), expand('$VIMRUNTIME'), expand($MY_VIMRUNTIME.'/after')], ',')
endif

" Set augroup.
augroup MyAutoCmd
  autocmd!
augroup END


"****************************************************************************
" Encoding:"{{{1
"****************************************************************************
"
" The automatic recognition of the character code.

" Setting of the encoding to use for a save and reading.
" Make it normal in UTF-8 in Unix.
set encoding=utf-8

" Setting of terminal encoding."{{{
if !has('gui_running')
  if &term == 'win32' || &term == 'win64'
    " Setting when use the non-GUI Japanese console.

    " Garbled unless set this.
    set termencoding=cp932
    " Japanese input changes itself unless set this.
    " Be careful because the automatic recognition of the character code is not possible!
    set encoding=japan
  else
    if $ENV_ACCESS ==# 'linux'
      set termencoding=euc-jp
    elseif $ENV_ACCESS ==# 'colinux'
      set termencoding=utf-8
    else  " fallback
      set termencoding=  " same as 'encoding'
    endif
  endif
elseif s:is_win
  " For system.
  set termencoding=cp932
endif
"}}}

" The automatic recognition of the character code."{{{
if !exists('did_encoding_settings') && has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'

  " Does iconv support JIS X 0213?
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  endif

  " Build encodings.
  let &fileencodings = 'ucs-bom'
  if &encoding !=# 'utf-8'
    let &fileencodings = &fileencodings . ',' . 'ucs-2le'
    let &fileencodings = &fileencodings . ',' . 'ucs-2'
  endif
  let &fileencodings = &fileencodings . ',' . s:enc_jis

  if &encoding ==# 'utf-8'
    let &fileencodings = &fileencodings . ',' . s:enc_euc
    let &fileencodings = &fileencodings . ',' . 'cp932'
  elseif &encoding =~# '^euc-\%(jp\|jisx0213\)$'
    let &encoding = s:enc_euc
    let &fileencodings = &fileencodings . ',' . 'utf-8'
    let &fileencodings = &fileencodings . ',' . 'cp932'
  else  " cp932
    let &fileencodings = &fileencodings . ',' . 'utf-8'
    let &fileencodings = &fileencodings . ',' . s:enc_euc
  endif
  let &fileencodings = &fileencodings . ',' . &encoding

  unlet s:enc_euc
  unlet s:enc_jis

  let did_encoding_settings = 1
endif
"}}}

if has('kaoriya')
  " For Kaoriya only.
  "set fileencodings=guess
endif

" When do not include Japanese, use encoding for fileencoding.
function! AU_ReCheck_FENC()
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding=&encoding
  endif
endfunction

autocmd MyAutoCmd BufReadPost * call AU_ReCheck_FENC()

" Default fileformat.
set fileformat=unix
" Automatic recognition of a new line cord.
set fileformats=unix,dos,mac

" Command group opening with a specific character code again."{{{
" In particular effective when I am garbled in a terminal.
command! -bang -bar -complete=file -nargs=? Utf8 edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? Cp932 edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Euc edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? Utf16 edit<bang> ++enc=ucs-2le <args>
command! -bang -bar -complete=file -nargs=? Utf16be edit<bang> ++enc=ucs-2 <args>
" Aliases.
command! -bang -bar -complete=file -nargs=? Jis  Iso2022jp<bang> <args>
command! -bang -bar -complete=file -nargs=? Sjis  Cp932<bang> <args>
command! -bang -bar -complete=file -nargs=? Unicode Utf16<bang> <args>
"}}}

" Tried to make a file note version."{{{
" Don't save it because dangerous.
command! WUtf8 setlocal fenc=utf-8
command! WIso2022jp setlocal fenc=iso-2022-jp
command! WCp932 setlocal fenc=cp932
command! WEuc setlocal fenc=euc-jp
command! WUtf16 setlocal fenc=ucs-2le
command! WUtf16be setlocal fenc=ucs-2
" Aliases.
command! WJis  WIso2022jp
command! WSjis  WCp932
command! WUnicode WUtf16
"}}}

" Handle it in nkf and open.
command! Nkf !nkf -g %

" Appoint a line feed."{{{
command! -bang -bar -complete=file -nargs=? Unix edit<bang> ++fileformat=unix <args>
command! -bang -bar -complete=file -nargs=? Mac edit<bang> ++fileformat=mac <args>
command! -bang -bar -complete=file -nargs=? Dos edit<bang> ++fileformat=dos <args>
command! -bang -complete=file -nargs=? WUnix write<bang> ++fileformat=unix <args> | edit <args>
command! -bang -complete=file -nargs=? WMac write<bang> ++fileformat=mac <args> | edit <args>
command! -bang -complete=file -nargs=? WDos write<bang> ++fileformat=dos <args> | edit <args>
"}}}

"****************************************************************************
" Input Japanese:"{{{1
"****************************************************************************
if has('multi_byte_ime')
  " Settings of default ime condition.
  set iminsert=0 imsearch=0
  nnoremap / :<C-u>set imsearch=0<CR>/
  xnoremap / :<C-u>set imsearch=0<CR>/
  nnoremap ? :<C-u>set imsearch=0<CR>?
  xnoremap ? :<C-u>set imsearch=0<CR>?
endif


"****************************************************************************
" Edit settings: {{{1
"****************************************************************************
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set clipboard+=unnamed
set hidden
set history=50
set virtualedit+=block
set wildmenu
set autoindent
set textwidth=0
if has('persistent_undo')
  let &undodir = $MY_VIMTMP . '/undo'
  set undofile
endif
set nobackup noswapfile nowritebackup
set viminfo='100,<50,s10,h,rA:,rB:,n$MY_VIMTMP/.viminfo
"set verbosefile=$MY_VIMTMP/.vim_vfile
"set undofile undodir=$MY_VIMTMP/.vim_undo

"Cインデントの設定
set cinoptions+=:0
"8進数を無効にする。<C-a>,<C-x>に影響する
set nrformats-=octal
"日本語の行の連結時には空白を入力しない
set formatoptions+=mM
"カーソルキーで行末／行頭の移動可能に設定
set whichwrap=b,s,[,],<,>
"バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
"□や○の文字があってもカーソル位置がずれないようにする
set ambiwidth=double

"****************************************************************************
" Search settings: {{{1
"****************************************************************************
set ignorecase smartcase
set wrapscan
set incsearch
set nohlsearch
"set iskeyword=a-z,A-Z,48-57,_,.,-,>

" grep
"set grepprg=internal
"let $CYGWIN = 'nodosfilewarning'
if s:is_win
  let &grepprg = 'grep -Hna --exclude=*.exe --exclude=*.dll --exclude=*.obj --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg'
else
  let &grepprg = 'grep -Hna --exclude=*.{exe,dll} --exclude-dir=.{svn,git,hg}'
endif

"****************************************************************************
" View settings: {{{1
"****************************************************************************
set number
"set relativenumber
set showcmd
set showmatch matchtime=1
set cmdheight=2
set list listchars=tab:\ \ ,trail:~,precedes:<,extends:>
set sidescroll=5
set linebreak
set nohlsearch
"set previewheight=12
set spelllang=en_us

"画面最後の行をできる限り表示する
set display=lastline
"スプラッシュ(起動時のメッセージ)を表示しない
"set shortmess+=I
"マクロ実行中などの画面再描画を行わない
"set lazyredraw

" ハイライトを有効にする
if &t_Co > 2 || has('gui_running')
  syntax on
endif

" title / status line
"----------------------------------------
let &titlestring="%{v:servername} (%{getcwd()})"
let &statusline = "%#Error#%m%#StatusLine#%r%{expand('%:t')} %<\(%{MySnipMid(expand('%:p:h'),80-len(expand('%:p:t')),'...')}\)%= %y%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}[%3l,%3c]"

function! MySnipMid(str, len, mask)
  if a:len >= len(a:str)
    return a:str
  elseif a:len <= len(a:mask)
    return a:mask
  endif

  let len_head = (a:len - len(a:mask)) / 2
  let len_tail = a:len - len(a:mask) - len_head

  return (len_head > 0 ? a:str[: len_head - 1] : '') . a:mask . (len_tail > 0 ? a:str[-len_tail :] : '')
endfunction

" 挿入モード時、ステータスラインのカラー変更
"----------------------------------------
let g:my_hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
  augroup MyAutoCmd
    au InsertEnter * call s:StatusLine('Enter')
    au InsertLeave * call s:StatusLine('Leave')
  augroup END
endif
let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:my_hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction

" diff/patch
"----------------------------------------
"diffの設定
"if s:is_win
"  set diffexpr=MyDiff()
"  function! MyDiff()
"    let opt = '-a --binary '
"    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
"    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
"    let arg1 = v:fname_in
"    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
"    let arg2 = v:fname_new
"    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
"    let arg3 = v:fname_out
"    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
"    let eq = ''
"    if $VIMRUNTIME =~ ' '
"      if &sh =~ '\<cmd'
"        let cmd = '""' . $VIMRUNTIME . '\diff"'
"        let eq = '"'
"      else
"        let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
"      endif
"    else
"      let cmd = $VIMRUNTIME . '\diff'
"    endif
"    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"  endfunction
"endif

"現バッファの差分表示(変更箇所の表示)
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
"ファイルまたはバッファ番号を指定して差分表示。#なら裏バッファと比較
command! -nargs=? -complete=file Diff if '<args>'=='' | browse vertical diffsplit|else| vertical diffsplit <args>|endif
"パッチコマンド
set patchexpr=MyPatch()
function! MyPatch()
   :call system($VIM."\\'.'patch -o " . v:fname_out . " " . v:fname_in . " < " . v:fname_diff)
endfunction


"****************************************************************************
" Key Mappings: {{{1
"****************************************************************************
" :help index
set notimeout nottimeout
"set whichwrap=b,s,[,],<,>,h,l

" Disable
map <F1> <Nop>

" Prefix Key
noremap <C-q> <Nop>
let g:mapleader = "\<C-q>"

noremap [Space] <Nop>
noremap [S-Space] <Nop>
noremap [C-Space] <Nop>
map <Space> [Space]
map <S-Space> [S-Space]
map <C-Space> [C-Space]


" Normal mode {{{2
"----------------------------------------------------------------------------
if s:is_win
  nnoremap <M-Space> :<C-u>simalt ~<CR>
endif
nnoremap ZZ <Nop>
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up>   gk
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <silent> [Space]/ :<C-u>call <SID>toggle_options('hls')<CR>

"split window
nnoremap [Space]sj :<C-u>execute 'belowright' (v:count == 0 ? '' : v:count) 'split'<CR>
nnoremap [Space]sk :<C-u>execute 'aboveleft'  (v:count == 0 ? '' : v:count) 'split'<CR>
nnoremap [Space]sh :<C-u>execute 'topleft'    (v:count == 0 ? '' : v:count) 'vsplit'<CR>
nnoremap [Space]sl :<C-u>execute 'botright'   (v:count == 0 ? '' : v:count) 'vsplit'<CR>

" Insert mode {{{2
"----------------------------------------------------------------------------
inoremap <silent><C-a>  <C-o>^
inoremap <C-d> <Del>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <A-b>  <S-Left>
inoremap <A-f>  <S-Right>

" Command-line mode {{{2
"----------------------------------------------------------------------------
cnoremap <C-d>  <Del>
cnoremap <C-a>  <Home>
cnoremap <C-e>  <End>
cnoremap <C-b>  <Left>
cnoremap <C-f>  <Right>
cnoremap <C-s>  <C-f>
cnoremap <C-l>  <C-d>
cnoremap <A-b>  <S-Left>
cnoremap <A-f>  <S-Right>

" Visual mode {{{2
"----------------------------------------------------------------------------
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
onoremap ) t)
onoremap ( t(
vnoremap ) t)
vnoremap ( t(

" other:
"----------------------------------------------------------------------------
" comments
" vmap [Space]c* :s/^\(.*\)$/\/\* \1 \*\//<CR>:nohlsearch<CR>
" vmap [Space]c( :s/^\(.*\)$/\(\* \1 \*\)/<CR>:nohlsearch<CR>
" vmap [Space]c< :s/^\(.*\)$/<!-- \1 -->/<CR>:nohlsearch<CR>
" vmap [Space]cd :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>:nohlsearch<CR>
vmap [Space]cb v`<I<CR><esc>k0i/*<ESC>`>j0i*/<CR><esc><ESC>
vmap [Space]ch v`<I<CR><esc>k0i<!--<ESC>`>j0i--><CR><esc><ESC>


"****************************************************************************
" Autocmd: {{{1
"****************************************************************************
augroup MyAutoCmd
  au BufNewFile,BufRead *.ng setf javascript
  au BufNewFile,BufRead *.afx setf afx
  au BufRead $MY_VIMRUNTIME/bundle/*,$MY_VIMRUNTIME/doc/*,$VIM/* setl noma ro
  au BufRead $HOME/doc/ref/* setl noma ro
  au BufRead $HOME/lib/* setl noma ro
  au BufRead $HOME/win32/local/nil/* setl noma ro
  "au QuickfixCmdPost make,grep,grepadd,vimgrep copen
  "autocmd BufNewFile *.html 0read $MY_VIMRUNTIME/templates/templete.html
  autocmd BufNewFile *.css 0read $MY_VIMRUNTIME/templates/style.css
  "ファイルを開いたら前回のカーソル位置へ移動
  au BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line('$') |
    \   exe "normal! g`\"" |
    \ endif
augroup END

augroup MyTest
  au!
augroup END


"****************************************************************************
" Scripts: {{{1
"****************************************************************************
" Toggle options. "{{{2
function! s:toggle_options(option_name)
  execute 'setlocal ' .a:option_name.'!'
  execute 'setlocal ' .a:option_name.'?'
endfunction

" Toggle variables. "{{{2
function! s:toggle_variable(variable_name)
  if eval(a:variable_name)
    execute 'let ' .a:variable_name.' = 0'
  else
    execute 'let ' .a:variable_name.' = 1'
  endif
  echo printf('%s = %s', a:variable_name, eval(a:variable_name))
endfunction

" Setting 'shellslash' off before call function() or exec command {{{2
"-----------------------------------------------------------------------------
if s:is_win
  function! s:my_nossl_run(is_func, name, ...)
    try
      let l:save_ssl = &ssl
      let &ssl = 0
      if a:is_func
        let l:parsed = s:nossl_parse_args(a:000, a:0, ',')
        let s:fn = function(a:name)
        call s:fn(l:parsed)
        unlet s:fn
      else
        let l:parsed = s:nossl_parse_args(a:000, a:0, ' ')
        exec a:name . " " . l:parsed
      endif
    catch
    finally
      let &ssl = l:save_ssl
      unlet l:save_ssl
    endtry
  endfunction

  function! s:nossl_parse_args(argline, cnt, sepChar)
    try
      let l:res = []
      let i = 0
      while i < a:cnt
        call add(l:res, a:argline[i])
        let i = i + 1
      endwhile
    catch
    endtry
    return join(l:res, a:sepChar)
  endfunction
endif



" :AllMaps {{{2
"-----------------------------------------------------------------------------
command! -nargs=* -complete=mapping
\   AllMaps
\   map <args> | map! <args> | lmap <args>


" Comment or uncomment lines from mark a to mark b. {{{2
"-----------------------------------------------------------------------------
nnoremap [Space]cc <Esc>:set opfunc=<SID>do_comment_op<CR>g@
nnoremap [Space]cd <Esc>:set opfunc=<SID>un_comment_op<CR>g@
vnoremap [Space]cc <Esc>:<C-u>call <SID>comment_mark(1,'<','>')<CR>
vnoremap [Space]cd <Esc>:<C-u>call <SID>comment_mark(0,'<','>')<CR>

function! s:comment_mark(docomment, a, b)
  if !exists('b:comment')
    let b:comment = s:comment_str() . ' '
  endif
  if a:docomment
    exe "normal! '" . a:a . "_\<C-V>'" . a:b . 'I' . b:comment
  else
    exe "'".a:a.",'".a:b . 's/^\(\s*\)' . escape(b:comment,'/') . '/\1/e'
  endif
endfunction

" Comment lines in marks set by g@ operator.
function! s:do_comment_op(type)
  call s:comment_mark(1, '[', ']')
endfunction

" Uncomment lines in marks set by g@ operator.
function! s:un_comment_op(type)
  call s:comment_mark(0, '[', ']')
endfunction

" Return string used to comment line for current filetype.
function! s:comment_str()
  if &ft ==# 'cpp' || &ft ==# 'java' || &ft ==# 'javascript'
    return '//'
  elseif &ft ==# 'vim'
    return '"'
  elseif &ft ==# 'python' || &ft ==# 'perl' || &ft ==# 'sh' || &ft ==# 'R' || &ft ==# 'ruby'
    return '#'
  elseif &ft ==# 'lisp'
    return ';'
  endif
  return ''
endfunction

" Command-line Window {{{2
"-----------------------------------------------------------------------------
" nnoremap : q:
" xnoremap : q:
" nnoremap : q:<C-u>

augroup MyAutoCmd
  autocmd  CmdwinEnter * call s:init_cmdwin()
augroup END

function! s:init_cmdwin()
  nnoremap <buffer> q :<C-u>quit<CR>
  nnoremap <buffer> <TAB> :<C-u>quit<CR>
  inoremap <buffer><expr><CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
  inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
  inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

  " Completion.
  inoremap <buffer><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

  startinsert!
endfunction


" Rename {{{2
"-----------------------------------------------------------------------------
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))

" 他のvimを閉じる {{{2
"---------------------------------------------------------------------------
nnoremap [S-Space]Q :<C-u>call <SID>kill_other_vim()<CR>
function! s:kill_other_vim()
  try
    for i in split(serverlist(), '\n')
      if i ==# 'GVIM'
        continue
      endif
      "call remote_send(i, '\<C-\>\<C-n>\<ESC>\<ESC>:qa!\<CR>')
      call remote_send(i, '<C-\><C-n><ESC><ESC>:qa!<CR>')
      sleep 50m
    endfor
  catch
  endtry
endfunction


" Open junk file {{{2
"---------------------------------------------------------------------------
command! -nargs=0 JunkFile call s:open_junk_file()
function! s:open_junk_file()
  "let l:junk_dir = $MY_VIMTMP . '/junk' . strftime('/%Y/%m')
  let l:junk_dir = $MY_VIMTMP . '/junk'
  if !isdirectory(l:junk_dir)
    call mkdir(l:junk_dir, 'p')
  endif

  let l:filename = input('Junk Code: ', l:junk_dir.strftime('/%Y-%m-%d-%H%M%S.'))
  if l:filename != ''
    execute 'edit ' . l:filename
  endif
endfunction


" :Transform {{{2
"   Like perl's "=~ tr/ABC/xyz/"
"---------------------------------------------------------------------------
" function Transform(from_group, to_group, target)
command! -nargs=* -range Transform <line1>,<line2>call Transform(<f-args>)
function! Transform(from_str, to_str, ...)
  if a:0 | let string = a:1 | else | let string = getline(".") | endif
  let from_ptr = 0 | let to_ptr = 0
  while 1
    let from_char = matchstr(a:from_str, '^.', from_ptr)
    if from_char == ''
      break
    endif
    let to_char = matchstr(a:to_str, '^.', to_ptr)
    let from_ptr = from_ptr + strlen(from_char)
    let to_ptr = to_ptr + strlen(to_char)
    let string = substitute(string, from_char, to_char, 'g')
  endwhile
  if a:0 | return string | else | call setline(".", string) | endif
endfunction

" :CdCurrent {{{2
"   Change current directory to current file's one.
"---------------------------------------------------------------------------
command! -nargs=0 CdCurrent cd %:p:h

" :Scratch {{{2
"   Open a scratch (no file) buffer.
"---------------------------------------------------------------------------
command! -nargs=0 Scratch new | setlocal bt=nofile noswf

" c_CTRL-X {{{2
"   Input current buffer's directory on command line.
"---------------------------------------------------------------------------
cnoremap <C-X> <C-R>=<SID>GetBufferDirectory()<CR>/
function! s:GetBufferDirectory()
  let path = expand('%:p:h')
  let cwd = getcwd()
  if match(path, cwd) != 0
    return path
  elseif strlen(path) > strlen(cwd)
    return strpart(path, strlen(cwd) + 1)
  else
    return '.'
  endif
endfunction

" :Undiff {{{2
"   Turn off diff mode for current buffer.
"---------------------------------------------------------------------------
command! -nargs=0 Undiff set nodiff noscrollbind wrap


"****************************************************************************
" Plugin: {{{1
"****************************************************************************

" pathogen.vim {{{2
"----------------------------------------------------------------------------
"command! -nargs=0 PathHelptags call pathogen#helptags()
"call pathogen#runtime_append_all_bundles()


" Shougo/neobundle.vim {{{2
"----------------------------------------------------------------------------
if s:is_win
  let g:my_vundle_git_cmd = $HOME . '\win32\etc\git-cd-pull.cmd'
endif

filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()
filetype plugin indent on

" original repos on github
"----------------------------
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/vimfiler'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/vimshell'
Bundle 'Shougo/unite.vim'
    Bundle 'tsukkee/unite-help'
    Bundle 'sgur/unite-everything'
    Bundle 'sgur/unite-qf'
    "Bundle 'Sixeight/unite-grep'
    Bundle 'Shougo/unite-grep'
    Bundle 'tacroe/unite-alias'
    Bundle 'tsukkee/unite-tag'

Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
    Bundle 'soh335/vim-ref-jquery'
    "Bundle 'pekepeke/ref-javadoc'
"Bundle 'thinca/vim-ft-vim_fold'

Bundle 'tpope/vim-surround'
"Bundle 'tpope/vim-fugitive'

"Bundle 'kana/vim-textobj-user'

Bundle 'clones/vim-align'
"Bundle 'clones/vim-taglist'

" vim-scripts repos
"----------------------------
"Bundle 'rails.vim'
Bundle 'xml.vim'

" non github repos
"----------------------------
"Bundle 'git://git.wincent.com/command-t.git'


" Shougo/neocomplcache {{{2
"----------------------------------------------------------------------------
let g:neocomplcache_snippets_dir=$MY_VIMRUNTIME . '/snippets'
let g:neocomplcache_temporary_dir=$MY_VIMTMP . '/.neocon'
"let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 0
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 3
"let g:neocomplcache_disable_auto_complete = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $MY_VIMTMP . '/.vimshell/.command-history',
    \ 'scheme' : $MY_VIMTMP . '/.gosh_completions'
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<TAB>"
"inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"


" Enable omni completion.
"----------------------------------------
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
"----------------------------------------
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'

" mappings
"----------------------------------------
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()
nnoremap [Space]nd :<C-u>NeoComplCacheDisable<CR>
nnoremap [Space]ne :<C-u>NeoComplCacheEnable<CR>

" SuperTab like snippets behavior.
"imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <expr><CR> neocomplcache#smart_close_popup()."\<CR>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplcache#smart_close_popup()."\<C-y>"
inoremap <expr><C-e> neocomplcache#smart_close_popup()."\<C-e>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"


" Shougo/unite.vim {{{2
"----------------------------------------------------------------------------
let g:unite_data_directory = $MY_VIMTMP . '/.unite'
"let g:unite_source_file_mru_file = g:unite_data_directory . '/.file_mru'
"let g:unite_source_bookmark_file = g:unite_data_directory . '/.bookmark'
"let g:unite_source_directory_mru_file = g:unite_data_directory . '/.dir_mru'
let g:unite_source_file_mru_limit = 100
"let g:unite_source_file_ignore_pattern = '\%(^\|/\)\.$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$'
"let g:unite_update_time = 200

" mappings
"----------------------------------------
" surround.vim のマッピングを無効化
augroup MyAutoCmd
  au FileType unite exec 'silent! nunmap ds'
  au BufWInLeave *[unite]* exec 'silent! nmap ds <Plug>Dsurround'
augroup END

" prefix key
nnoremap [unite] <Nop>
nmap     '       [unite]

if s:is_win
  nnoremap <silent> [unite]e  :<C-u>Unite -buffer-name=files -start-insert buffer bookmark file_mru everything<CR>
endif

nnoremap [unite]u  :<C-u>Unite<Space>
nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=files file<CR>
nnoremap <silent> [unite]b :<C-u>UniteWithBufferDir -buffer-name=files -prompt=%\  buffer file file_mru bookmark<CR>
nnoremap <silent> [unite]B :<C-u>Unite -buffer-name=files buffer<CR>
nnoremap <silent> [unite]m :<C-u>Unite -buffer-name=files -start-insert file_mru<CR>
nnoremap <silent> [unite]d :<C-u>Unite -buffer-name=files -start-insert directory_mru<CR>
nnoremap <silent> [unite]c :<C-u>UniteWithCurrentDir -buffer-name=files file<CR>
nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]q :<C-u>Unite -buffer-name=qf -no-quit qf<CR>
nnoremap <silent> [unite]Rc :<C-u>Unite -buffer-name=files -start-insert file_rec<CR>
"nnoremap <silent> [unite]t :<C-u>Unite -immediately tag:<C-r>=expand('<cword>')<CR><CR>
nnoremap <silent> [unite]t :<C-u>UniteWithCursorWord -buffer-name=tag tag<CR>
" alc
"-----------------------------------------------------
nnoremap <silent> [unite]w :<C-u>se ssl<CR>:<C-u>Unite file_rec:<C-r>=escape(globpath(g:ref_cache_dir,'alc'),':')<CR><CR>


" file_rec
"-----------------------------------------------------
" current dir
nnoremap [unite]Rc :<C-u>Unite -buffer-name=files -start-insert file_rec<CR>
" buffer dir
nnoremap [unite]Rb :<C-u>Unite -buffer-name=files -start-insert file_rec:<C-r>=escape(expand('%:p:h'),' :')<CR><CR>

" qf
"-----------------------------------------------------
"nnoremap [unite]gg :<C-u>Unite -no-quit qf:enc=utf-8:ex=<CR>grep <C-r>=expand('<cword>')<CR>
"nnoremap [unite]ga :<C-u>Unite -no-quit qf:enc=utf-8:ex=<CR>grepadd <C-r>=expand('<cword>')<CR>

" grep
"-----------------------------------------------------
 let g:unite_source_grep_default_opts = '-iRHna --exclude-dir=.{svn,git,hg}'
" current dir
 nnoremap [unite]gg :<C-u>Unite -no-quit grep<CR>
 nnoremap [unite]gc :<C-u>Unite -no-quit grep:.<CR>
 nnoremap [unite]gf :<C-u>Unite -no-quit grep:%<CR>

" .vim
"-----------------------------------------------------
nnoremap <silent> [unite]vf :<C-u>Unite -buffer-name=files -start-insert file_rec:~/.vim<CR>
nnoremap <silent> [unite]vh :<C-u>Unite help -start-insert<CR>
nnoremap <silent> [unite]vw :<C-u>UniteWithCursorWord help<CR>

" unite-alias
"----------------------------------------
let g:unite_source_alias_aliases = {
\   'vim' : {
\     'source': 'file_rec',
\     'args': $MY_VIMRUNTIME,
\   },
\   'afx' : {
\     'source': 'file_rec',
\     'args': $MY_TOOLS . '/afxw/menu',
\   },
\ }

" autocmd FileType unite call s:unite_my_settings()
" function! s:unite_my_settings()
" 
"   imap <buffer> jj      <Plug>(unite_insert_leave)
"   imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
" 
"   " Start insert.
"   "let g:unite_enable_start_insert = 1
" endfunction


" Shougo/vimshell {{{2
"----------------------------------------------------------------------------
let g:vimshell_temporary_directory = $MY_VIMTMP . '/.vimshell'
"let g:vimshell_vimshrc_path = expand('~/.vimshrc')
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
"let g:vimshell_right_prompt = 'vimshell#vcs#info("(%s)-[%b]", "(%s)-[%b|%a]")'
"let g:vimshell_external_history_path = ''

nmap [Space]vs <Plug>(vimshell_split_switch)

" autocmd MyAutoCmd FileType vimshell call s:vimshell_settings()
" 
" function! s:vimshell_settings()
"   nnoremap [Space]vi :<C-u>VimShellSendString<CR>
"   vnoremap [Space]vi :VimShellSendString<CR>
"   call vimshell#altercmd#define('g', 'git')
"   call vimshell#altercmd#define('i', 'iexe')
" endfunction



" Shougo/vimproc {{{2
"----------------------------------------------------------------------------


" Shougo/vimfiler {{{2
"----------------------------------------------------------------------------
"let g:loaded_netrwPlugin = 1
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_trashbox_directory	= $MY_VIMTMP . '/.vimfiler_trash'


autocmd! MyAutoCmd FileType vimfiler call s:vimfiler_settings()

function! s:vimfiler_settings()
  nmap <buffer>O <Plug>(vimfiler_sync_with_current_vimfiler)
  nmap <buffer>o <Plug>(vimfiler_sync_with_another_vimfiler)
  if has('Win32') || has('Win64')
    call vimfiler#set_execute_file('zip', $MY_TOOLS . '/esExt/esExt5')
    call vimfiler#set_execute_file('rar', $MY_TOOLS . '/esExt/esExt5')
  endif
endfunction


" thinca/vim-ref {{{2
"----------------------------------------------------------------------------
let g:ref_cache_dir = $MY_VIMTMP . '/.ref'
let s:my_ref_cmd = ''

if exists('*ref#register_detection')
  "call ref#register_detection('_', 'alc')
  call ref#register_detection('java', 'javadoc')
  call ref#register_detection('javascript', 'jquery', 'append')
  call ref#register_detection('php', 'phpmanual')
endif

"------------------------------------------------
" for Windows
"------------------------------------------------
if s:is_win
  let s:my_ref_cmd = 'lynx -display_charset=utf-8 -dump -nonumbers %s'

  " nossl
  command! -nargs=+ -complete=customlist,ref#complete MyRef
        \ call s:my_nossl_run(1, "ref#ref", <q-args>)
  nnoremap <silent> <Plug>(my-ref-keyword) :<C-u>call <SID>my_nossl_run(1, "ref#K", "normal")<CR>
  vnoremap <silent> <Plug>(my-ref-keyword) :<C-u>call <SID>my_nossl_run(1, "ref#K", "visual")<CR>
  nnoremap <Plug>(my-ref-keyword-alc) :<C-u>MyRef alc <C-r>=expand("<cword>")<CR>

  nmap [Space]r <Plug>(my-ref-keyword)
  vmap [Space]r <Plug>(my-ref-keyword)
  nmap [Space]e <Plug>(my-ref-keyword-alc)
endif

" source settings
"----------------------------------------
" alc
let g:ref_alc_cmd = s:my_ref_cmd
let g:ref_alc_use_cache = 1
let g:ref_alc_start_linenumber = 36
let g:ref_alc_encoding = 'utf-8'

" jsref
" let g:ref_jsref_cmd = s:my_ref_cmd

" jquery
let g:ref_jquery_cmd = s:my_ref_cmd
let g:ref_jquery_path = $HOME . '/doc/ref/jqapi-latest/docs'

" javadoc
let g:ref_javadoc_cmd = s:my_ref_cmd
let g:ref_javadoc_path = $HOME . '/doc/ref/javadoc/ja'

" php
let g:ref_phpmanual_cmd = s:my_ref_cmd
let g:ref_phpmanual_path = $HOME . '/doc/ref/phpman'


" flush
"----------------------------------------
unlet s:my_ref_cmd


" thinca/vim-quickrun {{{2
"----------------------------------------------------------------------------
let g:quickrun_config = {
\ '_' : {
\ 'split' : '10split',
\ },
\
\ 'cpp': {
\   'type': 'cpp/vc',
\ },
\ 'cpp/vc': {
\ 'command': 'cl',
\   'exec': ['%c %o %s /EHsc /nologo /Fo%s:p:r.obj /Fe%s:p:r.exe > nul',
\             '%s:p:r.exe %a', 'del %s:p:r.exe %s:p:r.obj'],
\ 'tempfile': '{tempname()}.cpp',
\  },
\ 'javascript':{
\   'type': 'javascript/spidermonkey',
\ },
\	}

function! MyQuickrunConfigSet(ft, key, val)
  let g:quickrun_config[a:ft][a:key] = a:val
endfunction

"nnoremap <silent> <Plug>(my-quickrun) :<C-u>call <SID>my_nossl_run(0, 'QuickRun', "-mode n")<CR>
"vnoremap <silent> <Plug>(my-quickrun) :<C-u>call <SID>my_nossl_run(0, 'QuickRun', "-mode v")<CR>

nmap [Space]q <Plug>(quickrun)
vmap [Space]q <Plug>(quickrun)


" tpope/vim-surround {{{2
"----------------------------------------------------------------------------


" vim-scripts/xml.vim {{{2
"----------------------------------------------------------------------------


" clone/vim-align {{{2
"----------------------------------------------------------------------------
let g:Align_xstrlen = 3


" clone/vim-taglist {{{2
"----------------------------------------------------------------------------
" 表示対象を変更
"let g:tlist_javascript_settings = 'javascript;v:var;c:class;p:prototype;m:method;f:function;o:object'
"let g:tlist_nilscript_settings = 'nilscript;v:var;c:class;p:prototype;m:method;f:function;o:object'


" myqfix.vim {{{2
"----------------------------------------------------------------------------
set rtp+=~/.vim/bundle/qfixapp
let g:QFix_CopenCmd = 'botright'
"let g:QFix_Width = 86

" mygrep.vim {{{2
"----------------------------------------------------------------------------
"外部grepの設定
let g:mygrepprg = 'grep'
"let g:MyGrepcmd_useropt = '--exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg'
"grep結果保存用
let g:MyGrep_Resultfile = $MY_VIMTMP . '/.greplog'
"grepの対象にしたくないファイル名の正規表現
let MyGrep_ExcludeReg = '[~#]$\|\.bak$\|\.o$\|\.obj$\|\.exe$\|[/\\]tags$'
"外部grep(shell)のエンコードを指定する。
if s:is_win
  let MyGrep_ShellEncoding = 'cp932'
endif
"「だめ文字」対策を有効/無効
let g:MyGrep_Damemoji = 2
"「だめ文字」を置き換える正規表現
let g:MyGrep_DamemojiReplaceReg = '(..)'
"「だめ文字」を自分で追加指定したい場合は正規表現で指定する。
let g:MyGrep_DamemojiReplace    = '[]'
"yagrepのマルチバイトオプション
"let g:MyGrep_yagrep_opt = 0

"Grepコマンドのキーマップ
let g:MyGrep_Key  = 'g'
"Grepコマンドの2ストローク目キーマップ
let g:MyGrep_KeyB = ','

"QFixGrepの検索時にカーソル位置の単語を拾う/拾わない
let g:MyGrep_DefaultSearchWord = 1

" myhowm.vim {{{2
"----------------------------------------------------------------------------
let g:howm_dir = $HOME . '/doc/howm'
let g:howm_filename = '%Y-%m-%d-%H%M%S.howm'
let g:howm_fileencoding = 'utf-8'
let g:howm_fileformat = 'unix'
"let g:QFixHowm_Key = 'g'
"let g:QFixHowm_KeyB = ','
"let g:QFixHowm_MenuDir = $HOME . '/doc/howm'
let g:QFixHowm_RecentMode = 2
let g:QFixHowm_OpenVimExtReg  = '\.txt$\|\.howm$\|\.vim$'
let g:QFixHowm_TitleFilterReg = '\[:private\]'
"let g:QFix_Height = 10
"ジャンプ先の行番号を変更する
let QFixHowm_MRU_SummaryLineMode = 1
" howm_dirの切替コマンド
" command! -nargs=1 HowmDir let g:howm_dir = <q-args> | echo howm_dir

" MRU
let QFixHowm_UseMRU = 1
let QFixHowm_MruFile    = $MY_VIMTMP . '/.howm_mru'
let QFixHowm_MruFileMax = 30

" Menu
let g:QFixHowm_Menufile = '__menu__.howm'
"let g:SubWindow_Title = $HOME . '/doc/howm/__submenu__.howm'
let g:SubWindow_Width = 30

" folding {{{
"let g:QFixHowm_FoldingPattern = '^[=.*]'
let g:QFixHowm_Folding = 0
augroup MyAutoCmd
  au BufNewFile,BufRead *.howm setlocal nofoldenable
  au BufNewFile,BufRead *.howm setlocal foldmethod=expr
  "au BufNewFile,BufRead *.howm setlocal foldexpr=getline(v:lnum)=~'^[.=*]'?'>1':'1'
  au BufNewFile,BufRead *.howm setlocal foldexpr=MyHowmFolding(v:lnum)
augroup END
function! MyHowmFolding(lnum)
  let l = getline(a:lnum)
  if l =~ '^='
    return '>1'
  elseif l =~ '^\[\d\{4}-\d\{2}-\d\{2}'
    return '1'
  elseif l =~ '^*'
    return '>2'
  else
    return '2'
  endif
endfunction "}}}

"gotoリンクを開くブラウザの指定
if s:is_win
  let QFixHowm_OpenURIcmd  = '!start "C:/Program Files/Mozilla Firefox/firefox.exe" %s'
else
  let QFixHowm_OpenURIcmd = "call system('firefox %s &')"
endif

" Template
let g:QFixHowm_Template = [
  \"= %TAG%",
  \""
\]


" kaoriya {{{2
"----------------------------------------------------------------------------
let g:plugin_autodate_disable = 1
let g:plugin_cmdex_disable = 1
let g:plugin_dicwin_disable = 1
let g:plugin_scrnmode_disable = 1
"let g:plugin_format_disable = 1
"let g:plugin_hz_ja_disable  = 1


" chalice.vim {{{2
"----------------------------------------------------------------------------
" >> $HOME/.gvimrc


" official {{{2
"----------------------------------------------------------------------------

" tohtml.vim
let g:loaded_2html_plugin = 1

" getscriptPlugin.vim
let g:GetLatestVimScripts_allowautoinstall= 0

" vimball.vim
nnoremap [Space]I :<C-u>let g:vimball_home = $MY_VIMRUNTIME . '/bundle/

" modeline:{{{1
unlet s:is_win
" vim:set ts=2 sts=2 sw=2 fdm=marker:
