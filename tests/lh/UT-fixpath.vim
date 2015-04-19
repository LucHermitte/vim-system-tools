"=============================================================================
" File:         addons/move2github/vim-system-tools/tests/lh/UT-fixpath.vim {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/vim-system-tools>
" Version:      2.2.0
" Created:      15th Mar 2015
" Last Update:  19th Apr 2015
"------------------------------------------------------------------------
" Description:
"       Test FixPathName()
" }}}1
"=============================================================================

UTSuite [system-tools] Testing FixPathName

runtime autoload/lh/system.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:CheckAgainst_fnameescape(path)
  let fpn = lh#system#FixPathName(a:path)
  let fne = fnameescape(a:path)
  AssertTxt(fpn == fne,
        \ 'FixPathName('.a:path.')='.fpn. ' != fnameescape(...)='.fne)
endfunction
function! s:Test_FixPathName()
  call s:CheckAgainst_fnameescape('/home/myself/foo/bar')
  call s:CheckAgainst_fnameescape('c:/home/myself/foo/bar')
  " call s:CheckAgainst_fnameescape('c:\home\myself\foo\bar')
  call s:CheckAgainst_fnameescape('foo bar')
  call s:CheckAgainst_fnameescape('c:/home/myself/foo bar')
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
