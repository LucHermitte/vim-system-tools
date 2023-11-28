"=============================================================================
" File:         autoload/lh/system.vim                                   {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.0
" Created:      03rd Feb 2007
" Last Update:  03rd Jul 2017
"------------------------------------------------------------------------
" Description:  VimL wrappers for external utilities and shells
"
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/
"       Requires Vim 7+
" History:
"        v2.0.0
"               Vim 7+ only
"               Code moved to autoload/lh/system.vim
"               Relies on lh-vim-lib
"        v2.1.0
"               Made compatible to lh-vim-lib 2.2.0
"        v2.1.1
"               SysCD()
"        v2.2.0
"               Functions moved to lh-vim-lib
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
if !exists('*SystemDetected')
  " This plugin must always be executed (first) order to have the &shellxxxx
  " properly set.
  runtime plugin/system_utils.vim
endif

"=============================================================================
" Function: FixPathName(pathname [, shellslash [, quote_char ]])        {{{1
function! lh#system#FixPathName(pathname,...) abort
  echomsg "lh#system#FixPathName is deprecated, please use lh#path#fix from lh-vim-lib"
  return call('lh#path#fix', [a:pathname] + a:000)
endfunction
" }}}1
"------------------------------------------------------------------------

" Function: UnixLayerInstalled() : boolean   {{{1
function! lh#system#UnixLayerInstalled()
  echomsg "lh#system#UnixLayerInstalled is deprecated, please use lh#os#has_unix_layer_installed from lh-vim-lib"
  return lh#os#has_unix_layer_installed()
endfunction

" Function: SystemDetected() : string        {{{1
function! lh#system#SystemDetected() abort
  echomsg "lh#system#SystemDetected is deprecated, please use lh#os#system_detected from lh-vim-lib"
  return lh#os#system_detected()
endfunction

" Function: OnDOSWindows()   : string        {{{1
function! lh#system#OnDOSWindows() abort
  echomsg "lh#system#OnDOSWindows is deprecated, please use lh#os#OnDOSWindows from lh-vim-lib"
  return lh#os#OnDOSWindows()
endfunction

" }}}1
"=============================================================================
" System functions         {{{1
" Function: SysPrint( file1 [, ...] ) : string               {{{2
function! lh#system#SysPrint(...)
  let res = lh#os#SystemCmd('print')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
        else
          echoerr "SysPrint: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysRemove( file1 [, ...] ) : string              {{{2
function! lh#system#SysRemove(...)
  let res = lh#os#SystemCmd('remove')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$'              | let a_i = '/?'
        elseif a:{i} =~ '^-r$\|-R\|^--r\%[ecursive]$' | let a_i = '/S'
        elseif a:{i} =~ '^-i$\|^--i\%[interactive]$'  | let a_i = '/P'
        elseif a:{i} =~ '^-f$\|^--f\%[orce]$'         | let a_i = '/F'
        else
          echoerr "SysRemove: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysRmdir( file1 [, ...] ) : string               {{{2
function! lh#system#SysRmdir(...)
  let res = lh#os#SystemCmd('rmdir')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
        else
          echoerr "SysRmdir: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysMkdir( file1 [, ...] ) : string               {{{2
function! lh#system#SysMkdir(...)
  let res = lh#os#SystemCmd('mkdir')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
        else
          echoerr "SysMkdir: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysCopy( file1 [, ...] ) : string                {{{2
function! lh#system#SysCopy(...)
  let res = lh#os#SystemCmd('copy')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$'              | let a_i = '/?'
        " elseif a:{i} =~ '^-r$\|-R\|^--r\%[ecursive]$' | let a_i = '/S'
        elseif a:{i} =~ '^-i$\|^--i\%[interactive]$'  | let a_i = '/-Y'
        elseif a:{i} =~ '^-f$\|^--f\%[orce]$'         | let a_i = '/Y'
        else
          echoerr "SysCopy: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysCopyDir( file1 [, ...] ) : string             {{{2
function! lh#system#SysCopyDir(...)
  let res = lh#os#SystemCmd('copydir')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$'              | let a_i = '/?'
        " elseif a:{i} =~ '^-r$\|-R\|^--r\%[ecursive]$' | let a_i = '/S'
        elseif a:{i} =~ '^-i$\|^--i\%[interactive]$'  | let a_i = '/-Y'
        elseif a:{i} =~ '^-f$\|^--f\%[orce]$'         | let a_i = '/Y'
        else
          echoerr "SysCopy: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysTouch( file1 [, ...] ) : string               {{{2
function! lh#system#SysTouch(...)
  let res = lh#os#SystemCmd("touch")
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
        else
          echoerr "SysTouch: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysMove( file1 [, ...] ) : string                {{{2
function! lh#system#SysMove(...)
  let res = lh#os#SystemCmd('move')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
        else
          echoerr "SysMove: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysCD( path [, ...] ) : string                   {{{2
function! lh#system#SysCD(...)
  return call('lh#os#sys_cd', a:000)
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysSort( file1 [, ...] ) : string                {{{2
function! lh#system#SysSort(...)
  let res = lh#os#SystemCmd('sort')
  let i = 0
  while i != a:0
    let i += 1
    if a:{i} =~ '^[-+]' " options
      if lh#system#SystemDetected() == 'msdos' && !lh#system#UnixLayerInstalled()
        if a:{i} =~ '^-k=\d\+$\|^--k\%[ey]=\d\+$'
          let a_i = substitute('-k=\|--k\%[ey]=', '/+', '')
        else
          echoerr "SysSort: Non portable option: ".a:{i}
          return ''
        endif
      else
        let a_i = a:{i}
      endif
    else                " files
      let a_i = lh#path#fix(a:{i})
    endif
    let res .= ' ' . a_i
  endwhile
  return res
endfunction
" }}}2
"=============================================================================
" Command: :EnsurePath     {{{1
"------------------------------------------------------------------------
" Main function        <public>  {{{2
" Returns 0 : 0  -> the directory hasn't been created successfully
"         1 : ok -> the directory has been created successfully
" Note: for MsWindows system, this function transforms the path before
" anything else.
function! lh#system#EnsurePath(path)
  let path = a:path
  if has("dos16") || has("dos32") || has('win32') || has('win16')
    " a- change every backslash to forwardslash (when not followed by a
    "    space) ... because of 'isdirectory()'
    let path = substitute(path, '\\\([^ ]\)', '/\1', 'g')
    " b- unescape the spaces ... still because of 'isdirectory()'
    let path = substitute(path, '\\ ', ' ', 'g')
    " call confirm('<'.path.(isdirectory(path)?'> exists': "> doesn't exist"), 'ok')
    " return
  endif
  return s:EnsurePath_core(path)
endfunction
" }}}2
"------------------------------------------------------------------------
" Main loop function   <private> {{{2
" Return 0 : 0
"        1 : ok
" Note: This function recursively builds the provided directory.
function! s:EnsurePath_core(path)
  " call input("isdirectory(".a:path.") = ".isdirectory(a:path))
  if !isdirectory(a:path)
    " A.1- Get parent directory.
    let up = substitute(a:path, '/\=[^/]*/\=$', '/', '')
    " call input("up = ".up)
    " A.2.a- If the parent is not root.
    if "" != up
      " call input("loop ".up)
      " A.2.a.i-  Recursivelly construct the parent directory.
      let r = s:EnsurePath_core(up)
      " A.2.a.ii- Return if an error has occurred.
      if r != 1
        " call input('r= '.r)
        return r
      endif
    endif
    " A.2.b- the parent is root, implicitely, don't recurse.
    " A.3- Construct the directory at the current level.
    " call input("Build ".a:path)
    let r = s:EnsurePathLastDepth(a:path)
    " call input('rlast= '.r)
    " A.4- Return the result of the construction.
    return r
  else
    " B- The current path exist : terminal condition.
    " call input(a:path." exist")
    return 1
  endif
  " call input("Problem")
endfunction
" }}}2
"------------------------------------------------------------------------
" Creation function    <private> {{{2
" Return 0 : 0
"        1 : ok
" Note: This function calls mkdir on the last part of the directory and
" checks that the creation went OK.
function! s:EnsurePathLastDepth(path)
  " call input("LastDepth isdirectory(".a:path.") = ".isdirectory(a:path))
  if !isdirectory(a:path)
    if filereadable(a:path) " {{{3
      call lh#common#error_msg("A file is found were a folder is expected : " . a:path)
      return 0  " exit
    endif " }}}3
    let v:errmsg=""
    if &verbose >= 1 | echo "Create <".a:path.">\n" | endif
    if     has("unix") " {{{3
      "TODO: I'll certainly have to escape the path, if so, please send me
      "an email.
      call system('mkdir '.a:path)
      " call system('mkdir '.escape(a:path, ' '))
      let path = a:path
    elseif has("win32") " {{{3
      if &shell =~ "sh"
        let path = a:path
        " let path = substitute(a:path,'\\','/', 'g')
        ""echo "system( 'mkdir ".path."')"
        call system('mkdir '.escape(path, ' '))
      else
        let path = substitute(a:path,'/','\\', 'g')
        let path = substitute(  path,'\\$','','')
        ""echo "system( 'md ".path."')"
        if (path =~ ' ') && (has("dos16") || has("dos32") || has('win95'))
          " system('md name with spaces do not work')
          silent exe '!md "'.path.'"'
          " Other solution if we don't want to wait for user to hit <enter>:
          " parse the path and replace non-terminal occurences of
          " directories having spaces in their name with the short name
          " equivalent ; ie. "C:\Program Files\foo" --> "C:\Progra~1\foo"
        else
          call system('md "'.path.'"')
        endif
      endif
    else " Other systems {{{3
      call lh#common#error_msg(
            \ "I don't know how to create directories on your system."
            \ "\nAny solution is welcomed! ".
            \ "Please, contact me at <hermitte"."@"."free.fr>")
    endif " }}}3
    "
    " ? any error ? {{{3
    if strlen(v:errmsg) != 0
      call lh#common#error_msg(v:errmsg)
      return 0
    elseif !isdirectory(a:path)
      call lh#common#error_msg("<".path."> can't be created!")
      return 0
    endif
    " }}}3
    return 1
  else
    return 0
  endif
endfunction
" }}}2
"------------------------------------------------------------------------
" Command: :Uniq           {{{1
" Function: lh#system#EmuleUniq() range
" Use: As it is a `range' function, call it with:
"       :%call EmuleUniq()
"       :'<,'>call EmuleUniq()
"       :3,6call EmuleUniq()
"       etc
function! lh#system#EmuleUniq() range
  let l1 = a:firstline
  let l2 = a:lastline
  if l1 < l2
    " Version1 from: Preben 'Peppe' Guldberg <peppe {at} xs4all {dot} nl>
    " silent exe l1 . ',' . (l2 - 1) . 's/^\(.*\)\%(\n\%<' . (l2 + 1)
          " \ . 'l\1$\)\+/\1/e'

    " Version from: Piet Delport <pjd {at} 303.za {dot} net>
    " silent exe l1.','l2.'g/^\%<'.l2.'l\(.*\)\n\1$/d'

    " Version1 from: Preben & Piet
    " <line1>,<line2>-g/^\(.*\)\n\1$/d
    silent exe l1.','l2.'-g/^\(.*\)\n\1$/d _'

    call histdel('search', -1)          " necessary
    " let @/ = histget('search', -1)    " useless within a function
  endif
endfunction

"------------------------------------------------------------------------
" }}}1
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
