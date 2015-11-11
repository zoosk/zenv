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

import sys

# Don't use colors if we are piping input into another program
if sys.stdout.isatty():
    RESET_ALL = '\033[0m'

    # Foreground colors
    BLACK       =   '\033[30m'
    RED         =   '\033[31m'
    GREEN       =   '\033[32m'
    YELLOW      =   '\033[33m'
    BLUE        =   '\033[34m'
    MAGENTA     =   '\033[35m'
    CYAN        =   '\033[36m'
    WHITE       =   '\033[37m'
    RESET_COLOR =   '\033[39m'

    # Formatting
    BOLD         =   '\033[1m'
    NO_BOLD      =   '\033[22m'
    UNDERLINE    =   '\033[4m'
    NO_UNDERLINE =   '\033[24m'
    BLINK        =   '\033[5m'
    NO_BLINK     =   '\033[25m'

    # Background colors
    BG_BLACK       =   '\033[40m'
    BG_RED         =   '\033[41m'
    BG_GREEN       =   '\033[42m'
    BG_YELLOW      =   '\033[43m'
    BG_BLUE        =   '\033[44m'
    BG_MAGENTA     =   '\033[45m'
    BG_CYAN        =   '\033[46m'
    BG_WHITE       =   '\033[47m'
    RESET_BG_COLOR =   '\033[49m'
else:
    RESET_ALL = ''

    # Foreground colors
    BLACK       =   ''
    RED         =   ''
    GREEN       =   ''
    YELLOW      =   ''
    BLUE        =   ''
    MAGENTA     =   ''
    CYAN        =   ''
    WHITE       =   ''
    RESET_COLOR =   ''

    # Formatting
    BOLD         =   ''
    NO_BOLD      =   ''
    UNDERLINE    =   ''
    NO_UNDERLINE =   ''
    BLINK        =   ''
    NO_BLINK     =   ''

    # Background colors
    BG_BLACK       =   ''
    BG_RED         =   ''
    BG_GREEN       =   ''
    BG_YELLOW      =   ''
    BG_BLUE        =   ''
    BG_MAGENTA     =   ''
    BG_CYAN        =   ''
    BG_WHITE       =   ''
    RESET_BG_COLOR =   ''


def format_string(string, *formats):
    """ Format a string using any color and format constants from this module. All formats will be reset at the end.
    :param string: The string to format.
    :param formats: Any number of color or format constants from this module.
    :return: The formatted string
    """
    return ''.join([''.join(formats), string, RESET_ALL])


# Preset formats
def success(string):
    """ A success message, bold and green """
    return ''.join([BOLD, GREEN, string, RESET_ALL])


def error(string):
    """ An error message, bold and red """
    return ''.join([BOLD, RED, string, RESET_ALL])


def title(string):
    """ A title, bold and underlined """
    return ''.join([BOLD, UNDERLINE, string, RESET_ALL])
