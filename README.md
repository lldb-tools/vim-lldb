vim-lldb
========

LLDB debugging in Vim for Python2 and Python3.

Installation
------------

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug '67hz/vim-lldb'
```

### Using [vundle](https://github.com/VundleVim/Vundle.Vim)

```vim
Plugin '67hz/vim-lldb'
```

- Make sure to use Vim 8.2 or above
- Have Python or Python3 support in Vim

vim-lldb Commands
--------

| Command           | List                                                                    |
| ---               | ---                                                                     |
| `:help lldb`      | plugin specific documentation                                           |
| `:Lhelp`          | LLDB's built-in help system (i.e lldb 'help' command)                   |
| `:Lscript help (lldb)` | Complete LLDB Python API reference                                |
| `:L<tab>`         | tab completion through all LLDB commands                                |



LLDB Commands
-------------

All LLDB commands are available through `:L<lldb_command>`. Using lldb's documentation at `:Lhelp` along with `:L<tab>` tab completion for all available LLDB commands is a good place to start. Remember to prepend all commands with `:L`.
For example:

```vim
" set a target file
:Ltarget ./path/to/file
" set a breakpoint under cursor
:Lbr
" run debugger
:Lrun
" get help for continue command
:Lhelp continue
```

Example commands:


| Command           | Function                                                                    |
| ---               | ---                                                                     |
| `:Ltarget file`   | specify target file                                                     |
| `:Lsettings set target.input-path <file>` | specify file input (exec < file)                |
| `:Lbr`            | set breakpoint under cursor                                             |
| `:Lrun`           | run                                                                     |
| `:Lstep`          | source level single step in current thread                              |
| `:Lnext`          | source level single step over in current thread                         |
| `:Lthread step-in` | instruction level single step in current thread                         |
| `:Lthread step-over` | instruction level single step-over in current thread                    |
| `Lcontinue`       | Continue execution of all threads in the current process.               |
| `:Lfinish`        | step out of currently selected frame                                    |
| `:Lthread return <RETURN EXPRESSION>`| return immediately from currently selected frame with optional return value |
| `:Lthread select 1`| select thread 1 as default thread for subsequent commands              |
| `:Lbt all`         | thread backtrace all                                                   |
| `:Lfr v`          | show args and local vars for current frame                              |
| `:Lfr v -f x bar` | show contents of variable `bar` formatted as hex                        |
| `:Lfr v -f b bar` | same as above with binary formatting                                    |
| `:Lregister read`  | show the general purpose registers for current thread                  |
| `:Lregister read rax rsp`  | show the contents of rax, rsp                                  |
| `:Lregister write rax 123`  | write `123` into rax                                          |
| `:Ldisassemble --name main` | disassemble any functions named `main`                        |
| `:Ldisassemble --line` | disassemble current source line for current frame                  |
| `:Ldisassemble --mixed` | disassemble with mixed mode                                       |



For a complete list of commands, see [gdb to lldb map](https://lldb.llvm.org/use/map.html)


Customization
-------------

### Global options


```vim
" add custom path to lldb
let g:lldb_path="/absolute/path/to/lldb"
```

```vim
" enable lldb, default is 1 {enable}, 0 {disable}
let g:lldb_enable = 1
```

```vim
" set lldb to async, default is 1 {async}, 0 {sync}
let g:lldb_async = 1
```

```vim
" set lldb console output color
:hi lldb_output ctermfg=green ctermbg=NONE guifg=green guibg=NONE
" set breakpoint color
:hi lldb_breakpoint ctermfg=white ctermbg=DarkGray guifg=white guibg=DarkGray
```


Verifying Python Support
------------------------

This plugin leverages the `LLDB` module which requires python support in vim. Vim's python version must match `LLDB`'s python interpreter version.

To verify Vim's python support, run:

    vim --version | grep python

The output must contain either `+python` or `+python3`

The above command displays the major version of vim. It is possible that a different minor/patch version is running between `LLDB` and python. To verify vim's exact python version, launch vim and run: 
 
     :pyx << EOF
     import sys
     print(sys.version)
     EOF
     
     " verify this output matches lldb's
     3.7.6 (default, ...)



Verify LLDB's version of python by launching the python interpreter in LLDB: 

    $> lldb
    (lldb) script
    Python Interactive Interpreter
    >>> import sys
    >>> print(svs.version)
    3.7.6 (default, ...)


If python versions are mismatched, either recompile Vim to match the same version as LLDB or vice-versa.

See **Customization** for specifying lldb path in `vimrc`.


