"=============================================================================
" File:         plugin/system_utils.vim                                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/vim-system-tools>
" Version:      3.0.0
" Created:      28th aug 2002
" Last Update:  04th Jan 2017
"------------------------------------------------------------------------
" Description:  VimL wrappers for external utilities and shells
"
"------------------------------------------------------------------------
" Installation: Drop the file in a {rtp}/plugin/ directory.
"               On MsWindows system, if you have installed unixutils or any
"               other unix-like text/file environment, then in your .vimrc,
"               set 'g:unix_layer_installed' to 1.
"
" Dependencies: Can take advantage of the presence of searchInRuntime.vim
"               Vim 6.0+
"
" History:      {{{2
"       v 3.0.0 Get rid of old functions
"       v 1.0   First version come from fix_d_name.vim and ensure_path.vim:
"               two plugins that, once, were parts of Triggers.vim.
"               Also includes the main part of _vimrc_win
"       v 1.07  Improvements, bug fixes and new commands :Uniq & :Sort
"       v 1.08  SysCat() changed into SysPrint()
"       v 1.09  Sort functions have been chaged to the very optimized ones
"               proposed by Piet Delport on Vim ML.
"               :Sort accept an optional argument: the name of a comparaison
"               function
"       v 1.10  EmuleUniq() doesn't mess with the unnamed register anymore.
"       v 1.11  Also use $CYGWIN to detect cygwin.
"       v 2.0.0
"               Vim 7+ only
"               Code moved to autoload/lh/system.vim
"               Relies on lh-vim-lib
"        v2.1.0
"               Made compatible to lh-vim-lib 2.2.0
"        v2.1.1
"               SysCD
"        v2.2.0
"               Functions moved to lh-vim-lib
"
" }}}2
" TODO:         Support other environments.
" }}}1
"=============================================================================

" Avoid reinclusion {{{1
if exists("g:loaded_system_utils") &&
      \ (!exists('g:force_reload_system_utils') || !g:force_reload_system_utils)
  finish
endif
let g:loaded_system_utils = 300
let s:cpo_save=&cpo
set cpo&vim
let s:sfile = expand('<sfile>:p')
" }}}1
"=============================================================================
" Function: FixPathName(pathname [, shellslash [, quote_char ]])        {{{1
function! FixPathName(pathname,...)
  echoerr "FixPathName is deprecated, please use lh#path#fix from lh-vim-lib"
  return call('lh#path#fix', [a:pathname] + a:000)
endfunction
" }}}1
"------------------------------------------------------------------------
" Function: UnixLayerInstalled() : boolean   {{{1
function! UnixLayerInstalled()
  return lh#system#UnixLayerInstalled()
endfunction

" Function: SystemDetected() : string        {{{1
function! SystemDetected() abort
  return lh#os#system_detected()
endfunction

" Function: s:DetectSystem()                 {{{1
function! s:DetectSystem()
  " if                *nix-like systems {{{2
  if &shell =~ 'sh' || lh#system#UnixLayerInstalled()
    if &shell !~ 'sh'
      let s:bin_path = ''
      let s:system = 'msdos'
    else
      " Problem: how to distinguish the use of unixutils-Zsh over cygwin-bash?
      if ($OSTYPE == "cygwin") || ($TERM == "cygwin") || ($CYGWIN != '')
        let s:bin_path = '/usr/bin/'
      else
        let s:bin_path = '\'
      endif
      let s:system = 'unix'
    endif
    let s:print  = s:bin_path.'cat'
    let s:remove = s:bin_path.'rm'
    let s:touch  = s:bin_path.'touch'
    let s:copy   = s:bin_path.'cp -p'
    let s:copydir= s:bin_path.'cp -pr'
    let s:move   = s:bin_path.'mv'
    let s:rmdir  = s:bin_path.'rm -r'
    let s:mkdir  = s:bin_path.'mkdir'
    let s:sort   = s:bin_path.'sort'
    let s:cd     = 'cd'

  " elseif            Windows & dos-like systems {{{2
  elseif
        \ has('win64') || has('win16') || has('win32') || has('dos16') || has('dos32')
        \ || has('os2')
    let s:system = 'msdos'
    let s:print  = 'type'
    let s:remove = 'del'
    let s:touch  = 'gvim -c wq'
    let s:copy   = 'copy'
    let s:copydir= 'xcopy /E/I'
    let s:move   = 'ren'
    let s:rmdir  = 'rd /S/Q'
    let s:mkdir  = 'md'
    let s:sort   = 'sort'
    let s:cd     = 'cd /D'
  else              " Other systems {{{2
    let s:system = 'unknown'
    call lh#common#error_msg(
          \ "I don't know the typical system-programs for your configuration."
          \."\nAny solution is welcomed! ".
          \ "Please, contact me at <hermitte"."@"."free.fr>")
  endif " }}}2
endfunction
" }}}1
"=============================================================================
" Command: Uniq()                                        {{{2

" ---
" Version from: Piet Delport <pjd {at} 303.za {dot} net>
" histdel() does not not in standalone in a command => cf the function
" command! -range=% Uniq
      " \ silent <line1>,<line2>g/^\%<<line2>l\(.*\)\n\1$/d
      " \ | let @/ =  (histdel("search", -1) ? histget("search", -1) : '')
" ---

command! -range=% -nargs=0 Uniq <line1>,<line2>call lh#system#EmuleUniq()

" }}}2
" System functions }}}1
"=============================================================================
" Command: :EnsurePath     {{{1
"------------------------------------------------------------------------
" Purpose:              {{{2
"       Proposes a command and a function that make sure a directory exists.
"       If the directory didn't exist before the call, it is created.
"       If the parent directories of the required directory do not exist, they
"       are created on the way.
" Implementation Notes: {{{2
" (*) isdirectory() seems to require paths defined with forward slashes (even
" on Win Me, command.com and 'shellslash'=0 ; and the spaces must not be
" escaped... It is too simple otherwise.
" (*) On the same WinMe :
"     - "system('md c:\verylongname')" and "system('md c:\verylongname\foo')"
"       work.
"     - "system('md c:\spaced name')" does not work !!!
"       while !md "c:\spaced name" does... That's very odd
"     - "system('md "c:\spaced name"')" does not work either ...
" (*) `mkdir' (from cygwin) is very permissive regarding the use of quotes and
" double-quotes. The only constraint is to have the spaces escaped.
" Tested on:            {{{2
"       WinMe + command.com
"       WinMe + cygwin (the VIM version, I used, being the one released on
"               the VIM web site and ftps for PC/MsWindows systems).
"               BTW, if you run VIM from the MsWindows files explorer and want
"               to use cygwin commands (like mkdir here), be sure to have your
"               $path correctly set.
"       WinXP + cygwin (same comments as above)
" Retest on:
"       Win95 + command.com & cygwin
"       WinNT + cmd32 & zsh & cygwin
"       Sun/Solaris + tcsh
" }}}2
"------------------------------------------------------------------------
command! -nargs=1 -complete=expression EnsurePath
      \ call lh#system#EnsurePath(<args>)
"------------------------------------------------------------------------
" }}}1
"=============================================================================
" Shells for dos & windows {{{1
if has('win16') || has('win32') || has('dos16') || has('dos32') || has('os2')
" ----------------------------------------------------------------------
" Commands {{{2
command! -nargs=0 GoBash :call s:Go_bash()
command! -nargs=0 GoZsh  :call s:Go_zsh()
command! -nargs=0 GoCmd  :call s:Go_cmd()
" }}}2
" ----------------------------------------------------------------------
"  Functions {{{2
function! s:Go_bash() " {{{3
  " Search bash.exe {{{4
  if filereadable('c:/cygwin/bin/bash.exe')
    set shell=c:\\cygwin\\bin\\bash.exe
  elseif filereadable('d:/cygwin/bin/bash.exe')
    set shell=d:\cygwin\bin\bash.exe
  else
    " Last chance : the cygwin path must be in the $PATH, and
    " searchInRuntime.vim available.
    if !exists(':SearchInPATH') " solve the loading order problem...
      :runtime plugin/searchInRuntime.vim macros/searchInRuntime.vim
    endif
    if exists(':SearchInPATH') " search bash
      command! -nargs=1 SetShell :exe ':let &shell=<q-args>'
      :SearchInPATH SetShell bash.exe
      delcommand SetShell
    endif
    if &shell !~ 'bash'  " bash not found...
      call confirm("Change the path to your bash installation.\n"
            \. 'Check <'.s:sfile.'>', '&OK', 1, "Error")
      return
    endif
  endif
  " Search bash.exe }}}4

  " set shellredir=">%s 2>&1"
  set shellredir=>%s\ 2>&1
  set shellpipe=2>&1\|\ tee
  set shellcmdflag=-c
  set shellquote=
  set shellxquote=\"
  " set shellxquote='"'
  set shellslash
  :call lh#os#DetectSystem()
endfunction " }}}3
" ----------------------------------------------------------------------
function! s:Go_zsh() " {{{3
  " Search Zsh {{{4
  if filereadable('d:/users/hermitte/bin/bin/sh.exe')
    set shell=d:\users\hermitte\bin\bin\sh
  elseif filereadable('c:/Program\ Files/Nix/Unixtools/bin/sh.exe')
    set shell=c:/Program\ Files/Nix/Unixtools/bin/sh.exe
  else
    " Last chance: zsh must be in the $PATH, and searchInRuntime.vim
    " available.
    if !exists(':SearchInPATH') " solve the loading order problem...
      :runtime plugin/searchInRuntime.vim macros/searchInRuntime.vim
    endif
    " Note: If cygwin is installed and visible from $PATH, this may find ash
    " instead.
    if exists(':SearchInPATH') " search zsh
      command! -nargs=1 SetShell :exe ':let &shell=<q-args>'
      :SearchInPATH SetShell zsh.exe sh.exe
      delcommand SetShell
    endif
    if &shell !~ 'sh'  " zsh not found...
      call confirm("Change the path to your Zsh installation.\n"
            \. 'Check <'.s:sfile.'>', '&OK', 1, "Error")
      return
    endif
  endif
  " Search Zsh }}}4
  set shellredir=>&
  set shellpipe=2>&1\|\ tee
  set shellcmdflag=-c
  set shellquote=
  set shellxquote=\"
  " set shellxquote='"'
  if version >= 600
    " Set shellslash in order to use correctly Cygwin.bat
    set shellslash
  endif
  :call lh#os#DetectSystem()
endfunction " }}}3
" ----------------------------------------------------------------------
function! s:Go_cmd() " {{{3
  if has("dos16") || has("dos32") || has('win16') || has('win95')
    " Or Windows Millenium
    set shell=command.com
    set noshellslash
  elseif has("win32")   " NT, 2000, XP (?) ; 95&Me if the previous case
    " set shell=C:\WINNT\system32\cmd.exe
    let &shell=$COMSPEC
    "set shellslash     ???
  else | return
  endif
  set shellcmdflag=/c
  set shellquote=
  set shellxquote=
  set shellredir=>
  set shellpipe=>
  :call lh#os#DetectSystem()
endfunction " }}}3
" }}}2
" ----------------------------------------------------------------------
" Auto-config {{{2
if ($OSTYPE == "cygwin") || ($TERM == "cygwin")
  " Cygwin
  :GoBash
elseif &sh =~ 'sh'
  " Unix tools
  :GoZsh
else
  " Microsoft's shell
  :GoCmd
endif
" Auto-config }}}2
" ----------------------------------------------------------------------
else
  " Do it on-the-fly when we need to do a CD or whatever
  " call lh#os#DetectSystem()
endif
" Shell }}}1
" ----------------------------------------------------------------------
"=============================================================================
let &cpo=s:cpo_save

"=============================================================================
" vim600: set fdm=marker:
" vim:    set sw=2:ts=8:
