if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

if has('Win32') || has('Win64')
  nnoremap <buffer> <F1> :<C-u>call MyQuickrunConfigSet('javascript', 'type', 'javascript/spidermonkey')<CR>
  nnoremap <buffer> <F2> :<C-u>call MyQuickrunConfigSet('javascript', 'type', 'javascript/cscript')<CR>
endif
