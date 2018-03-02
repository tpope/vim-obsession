" obsession.vim - Continuously updated session files
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.0
" GetLatestVimScripts: 4472 1 :AutoInstall: obsession.vim

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
      let file = substitute(fnamemodify(expand(a:file), ':p'), '[\/]$', '', '')
            \ . '/Session.vim'
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
    let &l:readonly = &l:readonly
  endtry
endfunction

function! s:persist() abort
  if exists('g:SessionLoad')
    return ''
  endif
  let sessionoptions = &sessionoptions
  if exists('g:this_obsession')
    try
      set sessionoptions-=blank sessionoptions-=options sessionoptions+=tabpages
      execute 'mksession! '.fnameescape(g:this_obsession)
      let body = readfile(g:this_obsession)
      call insert(body, 'let g:this_session = v:this_session', -3)
      call insert(body, 'let g:this_obsession = v:this_session', -3)
      call insert(body, 'let g:this_obsession_status = 2', -3)
      if type(get(g:, 'obsession_append')) == type([])
        for line in g:obsession_append
          call insert(body, line, -3)
        endfor
      endif
      call writefile(body, g:this_obsession)
      let g:this_session = g:this_obsession
      if exists('#User#Obsession')
        try
          let [save_mls, &modelines] = [&mls, 0]
          doautocmd User Obsession
        finally
          let &mls = save_mls
        endtry
      endif
    catch
      unlet g:this_obsession
      let &l:readonly = &l:readonly
      return 'echoerr '.string(v:exception)
    finally
      let &sessionoptions = sessionoptions
    endtry
  endif
  return ''
endfunction

function! ObsessionStatus(...) abort
  let args = copy(a:000)
  let numeric = !empty(v:this_session) + exists('g:this_obsession')
  if type(get(args, 0, '')) == type(0)
    if !remove(args, 0)
      return ''
    endif
  endif
  if empty(args)
    let args = ['[$]', '[S]']
  endif
  if len(args) == 1 && numeric == 1
    let fmt = args[0]
  else
    let fmt = get(args, 2-numeric, '')
  endif
  return substitute(fmt, '%s', get(['', 'Session', 'Obsession'], numeric), 'g')
endfunction

augroup obsession
  autocmd!
  autocmd VimLeavePre * exe s:persist()
  autocmd BufEnter *
        \ if !get(g:, 'obsession_no_bufenter') |
        \   exe s:persist() |
        \ endif
  autocmd User Flags call Hoist('global', 'ObsessionStatus')
augroup END

" vim:set et sw=2:
