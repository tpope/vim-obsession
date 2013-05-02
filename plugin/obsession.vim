" obsession.vim - Continuously updated session files
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.0

if exists("g:loaded_obsession") || v:version < 700 || &cp
  finish
endif
let g:loaded_obsession = 1

command! -bar -bang -complete=file -nargs=? Obsession execute s:dispatch(<bang>0, <q-args>)

function! s:dispatch(bang, file) abort
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
  else
    let file = expand(a:file, ':p')
    if empty(file)
      let file = fnamemodify(a:file, ':p')
    endif
    if isdirectory(a:file)
      let file = file . '/Session.vim'
    endif
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
endfunction

function! s:persist()
  if exists('g:this_obsession')
    let sessionoptions = &sessionoptions
    try
      set sessionoptions-=options
      execute 'mksession! '.fnameescape(g:this_obsession)
      call writefile(insert(readfile(g:this_obsession), 'let g:this_obsession = v:this_session', -2), g:this_obsession)
    catch
      unlet g:this_obsession
      return 'echoerr '.string(v:exception)
    finally
      let &sessionoptions = sessionoptions
    endtry
  endif
  return ''
endfunction

augroup obsession
  autocmd!
  autocmd BufEnter,VimLeavePre * exe s:persist()
augroup END

" vim:set et sw=2:
