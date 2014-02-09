" Plumber.vim - TDD via named pipes
" Author:      Stefano Verna <http://stefanoverna.com/>
" Version:     1.0.2

if !exists('g:plumber_use_dispatch')
  let g:plumber_use_dispatch = 0
endif

function! s:AlternateForFile(file)
  let substitutions =
    \ [
    \   [ '\vapp/(.*)\.rb', 'spec/\1_spec.rb' ],
    \   [ '\vlib/(.*)\.rb', 'spec/\1_spec.rb' ],
    \   [ '\v(.*)\.rb', 'spec/\1_spec.rb' ]
    \   [ '\vapp/(.*)\.rb', 'test/\1_test.rb' ],
    \   [ '\vlib/(.*)\.rb', 'test/\1_test.rb' ],
    \   [ '\v(.*)\.rb', 'test/\1_test.rb' ]
    \ ]

  for substitution in substitutions
    let result = matchstr(a:file, substitution[0])
    if len(result)
      let alternateFile = substitute(a:file, substitution[0], substitution[1], "g")
      if filereadable(alternateFile)
        return alternateFile
      end
    end
  endfor

  return ''
endfunction

function! s:CommandForTestFile(file)
  if a:file =~# '_spec.rb$'
    return "rspec " . a:file
  elseif a:file =~# '_test.rb$'
    return "ruby -Itest " . a:file
  elseif a:file =~# '.feature$'
    return "cucumber " . a:file
  elseif len(a:file) ># 0
    let alternateFile = s:AlternateForFile(a:file)
    return s:CommandForTestFile(alternateFile)
  endif
  return ''
endfunction

function! s:ExecutePlumbing(command)
  if g:plumber_use_dispatch
    exec "Dispatch " . a:command
  else
    let completeCommand = ""
    if exists("g:plumber_precommand")
      let completeCommand = completeCommand . g:plumber_precommand . " && "
    endif
    let command = a:command
    if exists("g:plumber_command_prefix")
      let command = g:plumber_command_prefix . " " . command
    endif
    let completeCommand = completeCommand . "echo " . command . " > .plumber"
    exec "silent !" . completeCommand
    echom completeCommand
    redraw!
  endif
endfunction

function! Plumber(command)
  if len(a:command) ># 0
    call s:ExecutePlumbing(a:command)
  else
    echom "No command valid for the specified file!"
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

