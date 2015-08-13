#! /usr/bin/env python2.7

##
# This is the installation file for ZEnv. It will create the ~/.zenvrc file with all of the user's settings
# defined in it.
#

from os import environ, unlink
from os.path import dirname, realpath, join
import re
import subprocess
from sys import stdin

from zenvlib import cli, colors


# Startup checks
if 'ZENV_INITIALIZED' in environ and environ['ZENV_INITIALIZED'] != '':
    print 'Please exit ZEnv before reinstalling it.'
    exit(1)

ZENV_ROOT = dirname(realpath(__file__))
if environ['PWD'] != ZENV_ROOT:
    print 'Please run the install script from the directory containing it.'
    exit(1)

# Read in the template global properties file
with open('properties/global.properties', 'r') as fp:
    props_template_lines = fp.read().split("\n")


settings_file_location = environ['HOME'] + '/.zenvrc'

print 'Hello and welcome to ZEnv. Please answer some questions to help set up your dev environment.'
print "Questions will be presented with default answers in parens. Just hit enter if you don't want to change them."
print ''

# Ask the only necessary global variable, the workspace root
default = environ['HOME'] + '/dev/workspace'
print ' Enter the path to where you store your checked-out git repositories (%s): ' % default,
ZENV_WORKSPACE = stdin.readline().rstrip("\n")
if ZENV_WORKSPACE == '':
    ZENV_WORKSPACE = default

# Ask the user for the requested vars
cli.fill_template_properties(props_template_lines)

# Add the pre-generated properties to the top of the file
props_template_lines.insert(0, """#! /usr/bin/env bash

######
## This is the global ZEnv settings file. If you want to change your global configuration without
## reinstalling everything, just modify the values in this file and then start a new terminal.
######

# The path to the ZEnv directory.
export ZENV_ROOT='""" + ZENV_ROOT + """'

# The location of this file.
export ZENV_SETTINGS='""" + settings_file_location + """'

# The folder containing all of your git repositories.
export ZENV_WORKSPACE='""" + ZENV_WORKSPACE + """'

# The name of the properties files used for checkouts.
export ZENV_WORKSPACE_SETTINGS='work.properties'
""")

# Add the initialization code to the bottom of the file
props_template_lines.append("""
############################## Anything below this line SHOULD NOT BE EDITED!!! ##############################

export PATH="${ZENV_ROOT}/bin:$PATH"
for i in $(find ${ZENV_ROOT}/environment -name '*.sh'); do
    source $i
done

export ZENV_INITIALIZED=1
""")

with open(settings_file_location, 'w') as fp:
    fp.write("\n".join(props_template_lines))

# Create the command alias in the right place
startup_file = cli.get_bash_startup_file()
with open(startup_file, 'r') as fp:
    startup_contents = fp.read()

new_alias = "alias zenv='" + ZENV_ROOT + "/activate.sh'"
if re.search('alias zenv=.*activate.sh', startup_contents) is None:
    startup_contents += "\n" + new_alias
else:
    startup_contents = re.sub('alias zenv=.*activate.sh', new_alias, startup_contents)

# Attempt to make ZEnv start by default
if re.search('source .*\.zenvrc', startup_contents) is None:
    print 'Would you like to set ZEnv to run on login [y/n] (y)? ',
    response = stdin.readline().strip()
    if response != 'n':
        startup_contents += """\n
### BEGIN ZENV INIT
source '""" + settings_file_location + """'
if [ -z \"$ZENV_CURRENT_WORK\" -a -n \"$(grep -m 1 ZENV \"$ZENV_WORKSPACE_SETTINGS\" 2>/dev/null)\" ]; then
    use $(python -c \"from os import path; print path.relpath('${PWD}', '${ZENV_WORKSPACE}')\")
fi
### END ZENV INIT
"""
    else:
        print 'You can start ZEnv at any time by typing "zenv".'

with open(startup_file, 'w') as fp:
    fp.write(startup_contents)
    
# Run the init script
setup_script = join(ZENV_ROOT, 'setupscripts', 'global.setup.sh')

return_code = subprocess.call(['bash', '--login', setup_script])
if return_code != 0:
    print 'An error in the setup script prevented the installation.'
    unlink(settings_file_location)
    exit(1)

print '%s %s' % (colors.format_string('<3', colors.RED, colors.BOLD),
                 colors.format_string("Setup is now complete! Restart your terminal and 'use' a checkout to begin using ZEnv.", colors.BOLD))
