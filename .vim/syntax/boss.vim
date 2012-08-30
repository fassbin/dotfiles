"=============================================================================
" boss.vim
if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"=============================================================================
syn region bossComment start=+^\\+ end=+$+
syn region bossStatement start=+^?+ end=+$+
syn region bossIdentifer start=+^%+ end=+$+

"=============================================================================
hi link bossComment Comment
hi link bossStatement Statement
hi link bossIdentifer Identifier

let b:current_syntax = "boss"
