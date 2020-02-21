
" Vim script glue code for LLDB integration
"

if !has('pythonx')
  call confirm('ERROR: This Vim installation does not have python support. lldb debugging is disabled.')
  finish
elseif (has('python3'))
  " prefer python3 to python2
  let s:lldb_python_version = 3
elseif (has('python'))
  let s:lldb_python_version = ""
endif

if(v:version < 801)
  call confirm('ERROR: lldb requires vim > v8.1.0. lldb debugging is disabled.')
  finish
endif 

if (exists("g:loaded_lldb") || (exists("g:lldb_enable") && g:lldb_enable == 0))
  finish
endif
let g:loaded_lldb = 1

let s:keepcpo = &cpo
set cpo&vim

" read in custom options from vimrc
let s:lldb_custom_path = ""
let s:lldb_async = 1 " async by default
let s:default_panes = []

if (exists("g:lldb_path"))
  let s:lldb_custom_path = g:lldb_path
endif

if (exists("g:lldb_default_panes"))
  let s:lldb_default_panes = g:lldb_default_panes
endif
if (exists("g:lldb_enable_async") && g:lldb_enable_async == 0)
  let s:lldb_async = 0
endif

function! s:Highlight()
  if !hlexists("lldb_output")
    :hi lldb_output ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE 
  endif
  if !hlexists("lldb_breakpoint")
    :hi lldb_breakpoint ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE 
  endif
  if !hlexists("lldb_pc_active")
    :hi lldb_pc_active ctermfg=White ctermbg=Blue guifg=White guibg=Blue
  endif
  if !hlexists("lldb_pc_inactive")
    :hi lldb_pc_inactive ctermfg=NONE ctermbg=LightGray guifg=NONE guibg=LightGray
  endif
  if !hlexists("lldb_changed")
    :hi lldb_changed ctermfg=DarkGreen ctermbg=White guifg=DarkGreen guibg=White
  endif
  if !hlexists("lldb_selected")
    :hi lldb_selected ctermfg=LightYellow ctermbg=DarkGray guifg=LightYellow guibg=DarkGray
  endif
endfunction



let s:script_dir = resolve(expand("<sfile>:p:h"))
function! s:FindPythonScriptDir()
  let base_dir = fnamemodify(s:script_dir, ':h')
  return base_dir . "/python-vim-lldb"
endfunction

function! s:InitLldbPlugin()

  " Setup the python interpreter path
  let vim_lldb_pydir = s:FindPythonScriptDir()
  execute 'pyx import sys; sys.path.append("' . vim_lldb_pydir . '")'
  " if import fails, lldb_disabled is set
  execute 'pyxfile ' . vim_lldb_pydir . '/plugin.py'

  if(exists("s:lldb_disabled"))
    return
  endif

  let g:vim_lldb_pydir = vim_lldb_pydir

  " Key-Bindings
  " FIXME: choose sensible keybindings for:
  " - process: start, interrupt, continue, continue-to-cursor
  " - step: instruction, in, over, out
  "
  if has('gui_macvim')
    " Apple-B toggles breakpoint on cursor
    map <D-B>     :Lbreakpoint<CR>
  endif

  "
  " Register :L<Command>
  " The LLDB CommandInterpreter provides tab-completion in Vim's command mode.
  " FIXME: this list of commands, at least partially should be auto-generated
  "
  "

  " Window show/hide commands
  command -complete=custom,s:CompleteWindow -nargs=1 Lhide               pyx ctrl.doHide('<args>')
  command -complete=custom,s:CompleteWindow -nargs=0 Lshow               pyx ctrl.doShow('<args>')
 
  " Launching convenience commands (no autocompletion)
  command -nargs=* Lstart                                                pyx ctrl.doLaunch(True,  '<args>')
  command -nargs=* Lrun                                                  pyx ctrl.doLaunch(False, '<args>')
  command -nargs=1 Lattach                                               pyx ctrl.doAttach('<args>')
  command -nargs=0 Ldetach                                               pyx ctrl.doDetach()

  " Regexp-commands: because vim's command mode does not support '_' or '-'
  " characters in command names, we omit them when creating the :L<cmd>
  " equivalents.
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpattach      pyx ctrl.doCommand('_regexp-attach', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpbreak       pyx ctrl.doCommand('_regexp-break', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpbt          pyx ctrl.doCommand('_regexp-bt', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpdown        pyx ctrl.doCommand('_regexp-down', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexptbreak      pyx ctrl.doCommand('_regexp-tbreak', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpdisplay     pyx ctrl.doCommand('_regexp-display', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpundisplay   pyx ctrl.doCommand('_regexp-undisplay', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregexpup          pyx ctrl.doCommand('_regexp-up', '<args>')

  command -complete=custom,s:CompleteCommand -nargs=* Lapropos           pyx ctrl.doCommand('apropos', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lbacktrace         pyx ctrl.doCommand('bt', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lbreakpoint        pyx ctrl.doBreakpoint('<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lcommand           pyx ctrl.doCommand('command', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Ldisassemble       pyx ctrl.doCommand('disassemble', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lexpression        pyx ctrl.doCommand('expression', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lhelp              pyx ctrl.doCommand('help', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Llog               pyx ctrl.doCommand('log', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lplatform          pyx ctrl.doCommand('platform','<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lplugin            pyx ctrl.doCommand('plugin', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lprocess           pyx ctrl.doProcess('<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lregister          pyx ctrl.doCommand('register', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lscript            pyx ctrl.doCommand('script', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lsettings          pyx ctrl.doCommand('settings','<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lsource            pyx ctrl.doCommand('source', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Ltype              pyx ctrl.doCommand('type', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lversion           pyx ctrl.doCommand('version', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=* Lwatchpoint        pyx ctrl.doCommand('watchpoint', '<args>')
 
  " Convenience (shortcut) LLDB commands
  command -complete=custom,s:CompleteCommand -nargs=* Lprint             pyx ctrl.doCommand('print', vim.eval("s:CursorWord('<args>')"))
  command -complete=custom,s:CompleteCommand -nargs=* Lpo                pyx ctrl.doCommand('po', vim.eval("s:CursorWord('<args>')"))
  command -complete=custom,s:CompleteCommand -nargs=* LpO                pyx ctrl.doCommand('po', vim.eval("s:CursorWORD('<args>')"))
  command -complete=custom,s:CompleteCommand -nargs=* Lbt                pyx ctrl.doCommand('bt', '<args>')

  " Frame/Thread-Selection (commands that also do an Uupdate but do not
  " generate events in LLDB)
  command -complete=custom,s:CompleteCommand -nargs=* Lframe             pyx ctrl.doSelect('frame', '<args>')
  command -complete=custom,s:CompleteCommand -nargs=? Lup                pyx ctrl.doCommand('up', '<args>',     print_on_success=False, goto_file=True)
  command -complete=custom,s:CompleteCommand -nargs=? Ldown              pyx ctrl.doCommand('down', '<args>', print_on_success=False, goto_file=True)
  command -complete=custom,s:CompleteCommand -nargs=* Lthread            pyx ctrl.doSelect('thread', '<args>')

  command -complete=custom,s:CompleteCommand -nargs=* Ltarget            pyx ctrl.doTarget('<args>')

  " Continue
  command -complete=custom,s:CompleteCommand -nargs=* Lcontinue          pyx ctrl.doContinue()

  " Thread-Stepping (no autocompletion)
  command -nargs=0 Lstepinst                                             pyx ctrl.doStep(StepType.INSTRUCTION)
  command -nargs=0 Lstepinstover                                         pyx ctrl.doStep(StepType.INSTRUCTION_OVER)
  command -nargs=0 Lstepin                                               pyx ctrl.doStep(StepType.INTO)
  command -nargs=0 Lstep                                                 pyx ctrl.doStep(StepType.INTO)
  command -nargs=0 Lnext                                                 pyx ctrl.doStep(StepType.OVER)
  command -nargs=0 Lfinish                                               pyx ctrl.doStep(StepType.OUT)


  " Bind/Unbind
  command -bar -bang Lunbind                call s:UnbindCursorFromLLDB()
  command -bar -bang Lbind                call s:BindCursorToLLDB()

  call s:ServiceLLDBEventQueue()
endfunction


" @TODO move this and other binding functions to /autoload
function! s:ServiceLLDBEventQueue()
  " hack: service the LLDB event-queue when the cursor moves
  " FIXME: some threaded solution would be better...but it
  "        would have to be designed carefully because Vim's APIs are non threadsafe;
  "        use of the vim module **MUST** be restricted to the main thread.
  command -nargs=0 Lrefresh pyx ctrl.doRefresh()
  call s:BindCursorToLLDB()
endfunction


function! s:BindCursorToLLDB()
  augroup bindtocursor
    autocmd!
    autocmd CursorMoved * :Lrefresh
    autocmd CursorHold  * :Lrefresh
    autocmd VimLeavePre * pyx ctrl.doExit()
  augroup end
endfunction


function! s:UnbindCursorFromLLDB()
  augroup bindtocursor
    autocmd!
  augroup end
  echo "vim-LLDB: unbound cursor"
endfunction


function! s:CompleteCommand(A, L, P)
pyx << EOF
a = vim.eval("a:A")
l = vim.eval("a:L")
p = vim.eval("a:P")
returnCompleteCommand(a, l, p)
EOF
endfunction

function! s:CompleteWindow(A, L, P)
pyx << EOF
a = vim.eval("a:A")
l = vim.eval("a:L")
p = vim.eval("a:P")
returnCompleteWindow(a, l, p)
EOF
endfunction

" Returns cword if search term is empty
function! s:CursorWord(term) 
  return empty(a:term) ? expand('<cword>') : a:term 
endfunction

" Returns cleaned cWORD if search term is empty
function! s:CursorWORD(term) 
  " Will strip all non-alphabetic characters from both sides
  return empty(a:term) ?  substitute(expand('<cWORD>'), '^\A*\(.\{-}\)\A*$', '\1', '') : a:term 
endfunction

augroup VimLLDB
  autocmd!
  au ColorScheme * call s:Highlight()
augroup END


call s:InitLldbPlugin()

call s:Highlight()


let &cpo = s:keepcpo
unlet s:keepcpo
