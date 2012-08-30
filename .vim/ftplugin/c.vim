if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:is_win = has('Win32') || ('Win64')

if s:is_win
  nnoremap <buffer><silent> <Plug>(quickrun) :<C-u>set nossl<CR>:QuickRun -mode n<CR>:set ssl<CR>
  vnoremap <buffer><silent> <Plug>(quickrun) :<C-u>set nossl<CR>:QuickRun -mode v<CR>:set ssl<CR>
  setl path+=C:/Program\\\ Files/Microsoft\\\ Visual\\\ Studio\\\ 10.0/VC/crt/src
endif
