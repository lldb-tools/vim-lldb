
# Locate and load the lldb python module

import vim
import os
import sys


def import_lldb():
    """ Find and import the lldb modules. This function tries to find the lldb module by:
       1. "import lldb" => in case the Vim's python installation is aware of lldb. If that fails,
       2. "s:lldb_path" => check if lldb_path is set in vimrc, if so, update and use full path as `lldb` below
       3. "lldb -P" => exec the lldb executable pointed to by the LLDB environment variable (or if unset, the first lldb on PATH") with the -P flag to determine the PYTHONPATH to set. If the lldb executable returns a valid
           path, it is added to sys.path and the import is attempted again. If that fails,
       4. On Mac OS X the default Xcode 4.5 installation path.
"""

    # Try simple 'import lldb', in case of a system-wide install or a
    # pre-configured PYTHONPATH
    try:
        import lldb
        return True
    except ImportError:
        pass

    # Allow overriding default path to lldb executable with the LLDB
    # environment variable
    lldb_executable = 'lldb'

    if 'LLDB' in os.environ and os.path.exists(os.environ['LLDB']):
        lldb_executable = os.environ['LLDB']

    # vimrc overrides environ ${LLDB}
    vimrc_lldb_path = vim.eval('s:lldb_custom_path')
    if vimrc_lldb_path != "":
        lldb_executable = vimrc_lldb_path

    # Try using builtin module location support ('lldb -P')
    from subprocess import check_output, CalledProcessError
    try:
        with open(os.devnull, 'w') as fnull:
            lldb_minus_p_path = check_output(
                "%s -P" %
                lldb_executable,
                shell=True,
                stderr=fnull).strip().decode("utf-8")

        if not os.path.exists(lldb_minus_p_path):
            # lldb -P returned invalid path, probably too old
            pass
        else:
            sys.path.append(lldb_minus_p_path)
            # print("DEBUG: importing from sys.path as lldb: %s"% lldb_minus_p_path)
            import lldb
            return True
    except CalledProcessError:
        # Cannot run 'lldb -P' to determine location of lldb python module
        pass
    except ImportError:
        # Unable to import lldb module from path returned by `lldb -P`
        pass

    # On Mac OS X, try the default path to XCode lldb module
    if "darwin" in sys.platform:
        python_major_version = vim.eval("s:lldb_python_version")
        xcode_python_path = "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/Current/Resources/Python%s/"% python_major_version
        sys.path.append(xcode_python_path)

        try:
            import lldb
            return True
        except ImportError:
            # Unable to import lldb module from default Xcode python path
            pass

    return False

if not import_lldb():
    vim.command("let s:lldb_disabled=1")
