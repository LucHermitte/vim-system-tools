"=============================================================================
" $Id$
" File:		autoload/lh/system.vim                                   {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	2.0.0
" Created:	03rd Feb 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	VimL wrappers for external utilities and shells
" 
"------------------------------------------------------------------------
" Installation:
" 	Drop this file into {rtp}/autoload/lh/
" 	Requires Vim 7+
" History:	
" 	 v2.0.0
" 		Vim 7+ only
" 		Code moved to autoload/lh/system.vim
" 		Relies on lh-vim-lib
" TODO:		«missing features»
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
" Function: FixPathName(pathname [, shellslash [, quote_char ]])	{{{1
function! lh#system#FixPathName(pathname,...) 
  " Parameters       {{{2
  " Ignore the last slash or backslash character, if any
  let pathname	 = matchstr(a:pathname, '^.*[^/\\]')
  " Default value for the quote character
  let quote_char = ''
  " Determine if 'shellslash' exists (dos-like platforms)
  if lh#system#OnDOSWindows()
    if lh#system#SystemDetected() == 'msdos'
      let shellslash = 0
    else
      let shellslash = &shellslash
    endif
  else "unix
    let shellslash = 1
  endif
  " Determine if we will use slashes or backslashes to distinguish directories
  if a:0 >= 1	" 
    let shellslash = a:1
    if a:0 >= 2
      let quote_char = a:2
    endif
  endif

  " Smart definition of quote chars for $COMSPEC
  if (lh#system#SystemDetected() == 'msdos') && !shellslash && (''==quote_char)
    if (&shell =~ 'command\.com') 
      if pathname =~ ' '
	" should also test long directory-names...
	" Best: AVOID command.com !!!
	if &verbose >= 1
	  call lh#common#ErrorMsg('FixPathName: '. 
		\ 'Problem expected because of the space in <'.pathname.'>')
	endif
      else
	let quote_char = ''
      endif
    else
      let quote_char = '"'
    endif
  endif

  " Fix the pathname {{{2
  if shellslash
    " return substitute(dname, '\\\([^ ]\|$\)', '/\1', 'g')
    let res = substitute(
	  \ substitute(pathname, '\\\([^ ]\|$\)', '/\1', 'g'),
	  \ '\(^\|[^\\]\) ', '\1\\ ', 'g')
  else
    " return substitute(
	  " \ substitute(pathname, '\([^\\]\) ', '\1\\ ', 'g'), 
	  " \ '/', '\\', 'g')
    let res = substitute(
	  \ substitute(pathname, '\\ ', ' ', 'g'), 
	  \ '/', '\\', 'g')
  endif
  " Note: problem to take care (that explains the complex substition schemes): 
  " sometimes the path passed to the function mix the two writtings, e.g.:
  " "c:\Program Files/longpath/some\ spaces/foo"
  " }}}2
  return quote_char . res . quote_char
endfunction
" }}}1
"------------------------------------------------------------------------
" Function: UnixLayerInstalled() : boolean   {{{1
function! lh#system#UnixLayerInstalled()
  return exists('g:unix_layer_installed') && g:unix_layer_installed
endfunction

" Function: SystemDetected() : string        {{{1
function! lh#system#SystemDetected()
  return SystemDetected()
endfunction

" Function: SystemDetected() : string        {{{1
function! lh#system#OnDOSWindows()
  return has('win16') || has('win32') || has('dos16') || has('dos32') || has('os2')
endfunction

" }}}1
"=============================================================================
" System functions         {{{1
" Function: SysPrint( file1 [, ...] ) : string               {{{2
function! lh#system#SysPrint(...)
  let res = SystemCmd('print')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysRemove( file1 [, ...] ) : string              {{{2
function! lh#system#SysRemove(...)
  let res = SystemCmd('remove')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysRmdir( file1 [, ...] ) : string               {{{2
function! lh#system#SysRmdir(...)
  let res = SystemCmd('rmdir')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysMkdir( file1 [, ...] ) : string               {{{2
function! lh#system#SysMkdir(...)
  let res = SystemCmd('mkdir')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysCopy( file1 [, ...] ) : string                {{{2
function! lh#system#SysCopy(...)
  let res = SystemCmd('copy')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysCopyDir( file1 [, ...] ) : string             {{{2
function! lh#system#SysCopyDir(...)
  let res = SystemCmd('copydir')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysTouch( file1 [, ...] ) : string               {{{2
function! lh#system#SysTouch(...)
  let res = SystemCmd("touch")
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysMove( file1 [, ...] ) : string                {{{2
function! lh#system#SysMove(...)
  let res = SystemCmd('move')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysSort( file1 [, ...] ) : string                {{{2
function! lh#system#SysSort(...)
  let res = SystemCmd('sort')
  let i = 0
  while i != a:0
    let i = i + 1
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
      let a_i = lh#system#FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
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
      call lh#common#ErrorMsg("A file is found were a folder is expected : " . a:path)
      return 0 	" exit
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
      call lh#common#ErrorMsg(
	    \ "I don't know how to create directories on your system."
	    \ "\nAny solution is welcomed! ".
	    \ "Please, contact me at <hermitte"."@"."free.fr>")
    endif " }}}3
    "
    " ¿ any error ? {{{3
    if strlen(v:errmsg) != 0
      call lh#common#ErrorMsg(v:errmsg)
      return 0
    elseif !isdirectory(a:path)
      call lh#common#ErrorMsg("<".path."> can't be created!")
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
" }}}1
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
