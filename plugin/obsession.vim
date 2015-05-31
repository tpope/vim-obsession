" obsession.vim - Continuously updated session files
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.0

if exists("g:loaded_obsession") || v:version < 700 || &cp
  finish
endif
let g:loaded_obsession = 1

command! -bar -bang -complete=file -nargs=? Obsession
      \ execute s:dispatch(<bang>0, <q-args>)

function! s:dispatch(bang, file) abort
  let session = get(g:, 'this_obsession', v:this_session)
  try
    if a:bang && empty(a:file) && filereadable(session)
      echo 'Deleting session in '.fnamemodify(session, ':~:.')
      call delete(session)
      unlet! g:this_obsession
      return ''
    elseif empty(a:file) && exists('g:this_obsession')
      echo 'Pausing session in '.fnamemodify(session, ':~:.')
      unlet g:this_obsession
      return ''
    elseif empty(a:file) && !empty(session)
      let file = session
    elseif empty(a:file)
      let file = getcwd() . '/Session.vim'
    elseif isdirectory(a:file)
      let file = fnamemodify(expand(a:file), ':p') . '/Session.vim'
    else
      let file = fnamemodify(expand(a:file), ':p')
    endif
    if !a:bang
      \ && file !~# 'Session\.vim$'
      \ && filereadable(file)
      \ && getfsize(file) > 0
      \ && readfile(file, '', 1)[0] !=# 'let SessionLoad = 1'
      return 'mksession '.fnameescape(file)
    endif
    let g:this_obsession = file
    let error = s:persist()
    if empty(error)
      echo 'Tracking session in '.fnamemodify(file, ':~:.')
      let v:this_session = file
      return ''
    else
      return error
    endif
  finally
    let &readonly = &readonly
  endtry
endfunction

function! s:persist() abort
  let sessionoptions = &sessionoptions
  if exists('g:this_obsession')
    try
      set sessionoptions-=blank sessionoptions-=options
      execute 'mksession! '.fnameescape(g:this_obsession)
      let body = readfile(g:this_obsession)
      call insert(body, 'let g:this_obsession = v:this_session', -3)
      call writefile(body, g:this_obsession)
    catch
      unlet g:this_obsession
      let &readonly = &readonly
      return 'echoerr '.string(v:exception)
    finally
      let &sessionoptions = sessionoptions
    endtry
  endif
  return ''
endfunction

function! ObsessionStatus(...) abort
  let numeric = !empty(s:this_session()) + exists('g:this_obsession')
  if !a:0
    return numeric
  elseif a:0 > 1
    return get(a:000, 2-numeric, '')
  endif
  let fmt = type(a:1) == type('') && a:1 =~# '^[^%]*%s[^%]*$' ? a:1 : '[%s]'
  if numeric == 2
    let status = 'Obsession'
  elseif numeric == 1
    let status = 'Session'
  else
    return ''
  endif
  return printf(fmt, status)
endfunction

augroup obsession
  autocmd!
  autocmd BufEnter,VimLeavePre * exe s:persist()
augroup END

" vim:set et sw=2:
