if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

nmap <buffer>O <Plug>(vimfiler_sync_with_current_vimfiler)
nmap <buffer>o <Plug>(vimfiler_sync_with_another_vimfiler)
if has('Win32') || has('Win64')
  call vimfiler#set_execute_file('zip', $MY_TOOLS . '/esExt/esExt5')
  call vimfiler#set_execute_file('rar', $MY_TOOLS . '/esExt/esExt5')
endif
