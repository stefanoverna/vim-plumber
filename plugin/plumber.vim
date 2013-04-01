" Plumber.vim - TDD via named pipes
" Author:      Stefano Verna <http://stefanoverna.com/>
" Version:     1.0

function! s:CommandForTestFile(file)
  if a:file =~# '_spec.rb$'
    return "rspec " . a:file
  elseif a:file =~# '_test.rb$'
    return "ruby -Itest " . a:file
  elseif a:file =~# '.feature$'
    return "cucumber " . a:file
  endif
  return ''
endfunction

function! Plumber(command)
  if len(a:command) ># 0
    let completeCommand = "silent !echo " . a:command . " > .plumber"
    echom "Executing \"" . completeCommand . "\""
    exec completeCommand
    redraw!
  end
endfunction

function! SendTestToPipe()
  let file = expand('%')
  let command = s:CommandForTestFile(file)
  echom command
  if len(command) ># 0
    let g:SendPipeLastCommand = command
  elseif exists("g:SendPipeLastCommand")
    let command = g:SendPipeLastCommand
  end
  return Plumber(command)
endfunction

function! SendFocusedTestToPipe()
  let file = expand('%')
  let command = s:CommandForTestFile(file)
  if len(command) ># 0
    let command = command . ":" . line('.')
    let g:SendPipeLastFocusCommand = command
  elseif exists("g:SendPipeLastFocusCommand")
    let command = g:SendPipeLastFocusCommand
  end
  return Plumber(command)
endfunction

" Mappings
nnoremap <silent> <leader>t :<C-U>w \| call SendTestToPipe()<CR>
nnoremap <silent> <leader>T :<C-U>w \| call SendFocusedTestToPipe()<CR>
