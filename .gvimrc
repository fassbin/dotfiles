scriptencoding utf-8

set columns=110
if &diff
   set columns=180
endif
set lines=80
set guioptions=e
set laststatus=2

"エラー時の音とビジュアルベルの抑制(gvimは.gvimrcで設定)
set noerrorbells
set novisualbell
set visualbell t_vb=

"colorscheme BlackSea
"colorscheme lucius
colorscheme mrkn256

"IMEの状態をカラー表示
if has('multi_byte_ime')
  highlight Cursor guifg=NONE guibg=Green
  highlight CursorIM guifg=NONE guibg=Purple
endif

" Font
"qwertyuiopasdfghjklzxcvbnm,./[];'1234567890-=!@#$%^&*()_+
"set guifont=MS_Gothic:h12:cSHIFTJIS
"let &guifont = 'Yutapon coding Regular:h12:cSHIFTJIS'
let &guifont = 'Yutapon coding RegularBackslash:h12:cSHIFTJIS'

" Plugin: {{{1

" Howm 
"if v:servername == 'howm' || v:servername == 'chalice'
"	call HowmRun()
"endif

" chalice 
if v:servername == 'chalice'
  set columns=180

  "let chalice_username = "KoRoN@Vim%Chalice"
  let chalice_anonyname = ""
  "let chalice_usermail = 'koron@tka.att.ne.jp'
  let chalice_columns = 180
  let chalice_boardlist_columns = 15
  let chalice_threadlist_lines = 10
  let chalice_bookmark = $HOME . '/.vim/chalice/chalice_bmk'
  let chalice_bookmark_backupinterval = 86400
  let chalice_cachedir = 'c:/fus/tmp/chalice'
  "let chalice_jumpmax = 1000
  "let chalice_menu_url = 'http://isweb36.infoseek.co.jp/computer/hima2908/bbsmenu.html'
  "let chalice_curl_options = '-x {host}:{port}'
  "let chalice_curl_options = '--connect-timeout 15 -m 30'
  "let chalice_curl_writeoptions = '--connect-timeout 30 -m 60'
  "let chalice_curl_cookies = 0
  let chalice_exbrowser_1 = 'C:\Program Files\Mozilla Firefox\Firefox.exe %URL% &'
  let chalice_exbrowser_0 = 'wget -P/' . $HOME . '/tmp/download %URL%'
  let chalice_reloadinterval_boardlist = 86400
  let chalice_reloadinterval_threadlist = 86400
  let chalice_threadinfo = 0
  "let chalice_threadinfo_expire = 7200
  "let chalice_gzip = 0
  "let chalice_multiuser = 1
  "let chalice_foldmarks = '●○'
  let chalice_statusline = '%c,'
  "let chalice_noquery_write = 1
  let chalice_startupflags = 'bookmark,aa=no'
  let chalice_preview = 0
  let chalice_previewflags = 'above'
  "let chalice_noredraw = 1
  let chalice_writeoptions = "amp,nbsp2,zenkaku"
  "let chalice_autonumcheck = 1
  "let chalice_verbose = 1
  "let chalice_ngwords = '^山崎渉'
  "let chalice_ngwords = '^山崎渉' ."\<NL>". '^IP記録実験'
  "let chalice_localabone = ',,'
  "let chalice_loginid = 'chalice@kaoriya.net'
  "let chalice_password = 'password_phrase'
  "let chalice_formatedcache_expire = 7
  "let chalice_readoptions = "noenc"
  "let chalice_cruise_endmark = '巡回終了'
  set runtimepath+=$HOME/.vim/chalice
  runtime plugin/chalice.vim
endif

winpos 1108 30
"set columns=80
"set lines=40
"winpos 50 50

" vim:set ts=2 sts=2 sw=2 fdm=marker:
