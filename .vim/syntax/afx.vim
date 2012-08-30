"=============================================================================
" test.vim
if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"=============================================================================
syn match afxComment '^;.*$'
syn match afxStatement '&' nextgroup=afxStateName
syn match afxMacro '\$' nextgroup=afxMacroName,afxMacroNameI
syn region afxString start=+"+ end=+"+ contains=afxMacro
syn region afxDescription start=+^"+ end=+"+

syn case ignore
syn keyword afxStateName contained nop reload exec open close wavplay wavstop context extract v_arc susie s_arc cd excd mask mark sort clip mesclip max min pushd popd set copyto moveto meltto copyhis movehis ldropto rdropto wdropto divide connect ccto cmto view edit prpty tow mks_u mks_d eject each eachnw regren reld_rd vspmv hspmv menu pmenu 
syn keyword afxMacroName contained p f t c f w e p o l r sp so sl sr ms mf mo it mn mt mp v k n d cp co cl cr ca j qn
syn match afxMacroName contained "\d"
syn match afxMacroNameI contained "i" nextgroup=afxMacroNameI2
syn match afxMacroNameI2 contained "\d"

"=============================================================================
hi link afxComment Comment
hi link afxStatement Statement
hi link afxMacro Type
hi link afxString String
hi link afxDescription Identifier

hi link afxStateName afxStatement
hi link afxMacroName afxMacro
hi link afxMacroNameI afxMacro
hi link afxMacroNameI2 afxMacro

let b:current_syntax = "afx"
