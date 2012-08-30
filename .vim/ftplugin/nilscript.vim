"lcd ~/bin/nil
nnoremap <buffer> <Leader>e :!d:/fus/bin/nil/ng<space>%<CR>

"preview interpreter's output(Tip #1244)
"function! Ruby_eval_vsplit() range
"        let src = tempname()
"        let dst = "Nilscript Output"
"        " put current buffer's content in a temp file
"        silent execute ":" . a:firstline . "," . a:lastline . "w " . src
"        " open the preview window
"        silent execute ":pedit! " . dst
"        " change to preview window
"        wincmd P
"        " set options
"        setlocal buftype=nofile
"        setlocal noswapfile
"        setlocal syntax=none
"        setlocal bufhidden=delete
"        " replace current buffer with ruby's output
"        silent execute ":%!ng " . src . " > tmp.txt"
"		silent execute ":e tmp.txt"
"        " change back to the source buffer
"        wincmd p
"endfunction
""<F10>でバッファのRubyスクリプトを実行し、結果をプレビュー表示
"vmap <silent> <F10> :call Ruby_eval_vsplit()<CR>
"nmap <silent> <F10> mzggVG<F10>`z
"map  <silent> <S-F10> :pc<CR>
