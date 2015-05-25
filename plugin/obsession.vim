" obsession.vim - Continuously updated session files
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.0

if exists("g:loaded_obsession") || v:version < 700 || &cp
  finish
endif
let g:loaded_obsession = 1

command! -bar -bang -complete=file -nargs=? Obsession execute s:dispatch(<bang>0, <q-args>)

function! s:dispatch(bang, file) abort
  try
    if a:bang && empty(a:file) && filereadable(get(g:, 'this_obsession', v:this_session))
      echo 'Deleting session in '.fnamemodify(get(g:, 'this_obsession', v:this_session), ':~:.')
      call delete(get(g:, 'this_obsession', v:this_session))
      unlet! g:this_obsession
      return ''
    elseif empty(a:file) && exists('g:this_obsession')
      echo 'Pausing session in '.fnamemodify(g:this_obsession, ':~:.')
      unlet g:this_obsession
      return ''
    elseif empty(a:file) && !empty(v:this_session)
      let file = v:this_session
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
  if exists('g:this_obsession')
    let sessionoptions = &sessionoptions
    try
      set sessionoptions-=blank sessionoptions-=options
      execute 'mksession! '.fnameescape(g:this_obsession)
      call writefile(insert(readfile(g:this_obsession), 'let g:this_obsession = v:this_session', -2), g:this_obsession)
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
  if !a:0
    return !empty(v:this_session) + exists('g:this_obsession')
  endif
  let fmt = type(a:1) == type('') && a:1 =~# '^[^%]*%s[^%]*$' ? a:1 : '[%s]'
  if empty(v:this_session)
    return ''
  elseif exists('g:this_obsession')
    let status = 'Obsession'
  else
    let status = 'Session'
  endif
  return printf(fmt, status)
endfunction

augroup obsession
  autocmd!
  autocmd BufEnter,VimLeavePre * exe s:persist()
augroup END

" vim:set et sw=2:
