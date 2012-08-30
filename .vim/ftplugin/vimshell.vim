if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

nnoremap [Space]vi :<C-u>VimShellSendString<CR>
vnoremap [Space]vi :VimShellSendString<CR>
call vimshell#altercmd#define('g', 'git')
call vimshell#altercmd#define('i', 'iexe')
