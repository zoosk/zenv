#   Copyright 2015 Zoosk, Inc
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

from os.path import basename, exists, expanduser
import pipes
import re
import subprocess
import sys

from zenvlib import environ


def fail_without_zenv():
    """ Exit the current runtime if ZEnv is not initialized. """
    if not environ.initialized:
        print 'You must be using ZEnv to run this program.'
        sys.exit(1)


def fail_without_workspace():
    """ Exit the current runtime if there is no workspace selected. """
    if not environ.initialized or not environ.current_work:
        print 'You must be using a checkout in ZEnv to run this program.'
        sys.exit(1)


def check_usage(usage=None, min_args=0, max_args=None):
    """ If the user passed --help or -h to the program, print the given usage message and exit.
    :param usage_str: The usage message for the program, using '%N' for the program name.
    """
    progname = basename(sys.argv[0])

    # Get default usage string
    if usage is None:
        if min_args > 0:
            args = ' ' + ' '.join('arg%d' % (i+1) for i in xrange(min_args))
        else:
            args = ''
        usage = 'Usage: %s%s' % (progname, args)
    else:
        usage = usage.replace('%P', progname)

    # Check to see if help was requested
    if '--help' in sys.argv or '-h' in sys.argv:
        print usage
        sys.exit(0)

    # Check the minimum positional args
    if len(sys.argv) - 1 < min_args:
        print usage
        sys.exit(1)

    if max_args is not None and len(sys.argv) - 1 > max_args:
        print usage
        sys.exit(1)


def fill_template_properties(props_template_lines):
    """ Fill in the values of @@-delimited values in a template properties file.
    :param props_template_lines: A list of lines in the file.
    :return: None; however, the original array will be modified with the new values.
    """
    for line_index in xrange(len(props_template_lines)):
        line = props_template_lines[line_index].rstrip()

        match = re.findall('^export\s*(.*?)=.*@@(.*?)@@', line)
        if len(match) > 0:
            # Get the var name and possibly default value
            var_name, default = match[0]

            # Expand variables in the default value
            if default != '':
                # include variables rendered in previous lines as environment
                env = [l for l in props_template_lines[:line_index] if l.startswith('export')]
                default = expand_shell_expr(default, env)

            # Check for a comment on the line before
            question = None
            if line_index != 0:
                prev_line = props_template_lines[line_index - 1]
                if prev_line.startswith('#'):
                    question = 'Enter %s (%s): ' % (prev_line[1:].strip(), default)

            if question is None:
                question = 'Enter the value for the global %s variable (%s): ' % (var_name, default)

            # Put the user's value into the file
            print question,
            value = sys.stdin.readline().rstrip()
            if value == '':
                value = default

            props_template_lines[line_index] = re.sub('@@(.*?)@@', pipes.quote(value), line)


def expand_shell_expr(expression, env=[]):
    """ Return an expanded version of the bash variables in a given expression.
    """
    cmd = '; '.join(env + ['echo ' + expression])
    return subprocess.check_output(['bash', '-c', cmd]).rstrip()


def get_bash_startup_file():
    """ Determine which startup file bash will use, and return a path to it.
    :return: The path to the startup file that bash will use, for example to .bash_login or .bash_profile
    """
    home = expanduser('~')
    files = ['.bash_profile', '.bash_login', '.profile']
    for f in files:
        if exists(home + '/' + f):
            return home + '/' + f

    # If no files exist, default to .bash_login since that's commonly used by MacPorts
    return home + '/.bash_login'
