from os.path import basename
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
