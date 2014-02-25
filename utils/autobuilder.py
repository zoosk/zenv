#! /usr/bin/env python

try:
    from fsevents import Observer
    from fsevents import Stream
except ImportError:
    print 'You need to install fsevents to be able to watch for changes. Please run sudo easy_install macfsevents.'
    exit(1)

import os
from os.path import basename
from os.path import dirname
from os.path import exists
from os.path import relpath
from os.path import splitext
from pipes import quote
import re
import signal


# Settings
BUILD_SETTINGS_FILE = 'autobuild_settings'
DEBUG = False

# Events
UPDATE_EVENT = 0x2
ADD_EVENT = 0x100
DELETE_EVENT = 0x200

# Keywords
KEY_COMMENT = '#'
KEY_SET = 'set'
KEY_ALL = 'all'
KEY_ADD = 'add'
KEY_UPDATE = 'update'
KEY_DELETE = 'delete'
KEY_ADDUP = 'addupdate'
KEY_ADDDEL = 'adddelete'
KEY_UPDEL = 'updatedelete'

# Excluded file names
EXCLUDED_FILE_NAMES = set([
    BUILD_SETTINGS_FILE,
    'build.xml',
    'Makefile'
])


if 'ZENV_CURRENT_WORK' not in os.environ:
    print 'You must use a workspace before you start robuild.'
    exit(1)

local_path = os.environ['ZENV_CURRENT_WORK']
server_path = os.environ['ZENV_SERVERDIR']


def is_excluded_path(path):
    return '.svn' in path or '.idea' in path or '/sass-cache' in path or '.git' in path

def is_excluded_filename(name):
    """ Check if a file should be excluded from builds. """
    return name.startswith('.') or name.startswith('#') or name.endswith('~') or name in EXCLUDED_FILE_NAMES

def callback(event):
    """ Callback function for when a file is changed. """
    if DEBUG:
        print 'Caught event %d for %s' % (event.mask, event.name)
    if (event.mask == UPDATE_EVENT or event.mask == ADD_EVENT or event.mask == DELETE_EVENT) and not is_excluded_path(event.name):
        # Get the name of the changed file
        filename = basename(event.name)
        if is_excluded_filename(filename):
            print '%s was changed, and is excluded.' % filename
            return

        # Travel up the directory structure until we find one with a settings file in it
        extra_dirs = []
        settings_dir = dirname(event.name)
        while not exists(settings_dir + '/' + BUILD_SETTINGS_FILE) and settings_dir != '/':
            extra_dirs.insert(0, basename(settings_dir)+'/')
            settings_dir = dirname(settings_dir)

        if DEBUG:
            print 'Directory with settings file is %s' % settings_dir

        if settings_dir == '/':
            # This is certainly not a workspace
            print 'Could not find a settings file appropriate for %s.' % event.name
            return

        # Get the kind of rules that we are looking for
        if event.mask == UPDATE_EVENT:
            rules_to_run = set([KEY_ALL, KEY_UPDATE, KEY_ADDUP, KEY_UPDEL])
        elif event.mask == ADD_EVENT:
            rules_to_run = set([KEY_ALL, KEY_ADD, KEY_ADDUP, KEY_ADDDEL])
        elif event.mask == DELETE_EVENT:
            rules_to_run = set([KEY_ALL, KEY_DELETE, KEY_ADDDEL, KEY_UPDEL])
        else:
            print 'OH GOD AN UNHANDLED EVENT'
            return

        # Get the contents of the settings file
        matched_rule = None
        commands = None
        envs = []
        rules = []
        with open(settings_dir + '/' + BUILD_SETTINGS_FILE) as fp:
            while matched_rule is None:
                line = fp.readline()

                # Read the variable settings
                if line.startswith(KEY_SET):
                    env_name, env_value = re.search('%s ([^=]+)=(.*)' % KEY_SET, line).groups()
                    envs.append('%s=%s' % (env_name, env_value))
                    if DEBUG:
                        print 'Found a variable declaration: %s = %s' % (env_name, env_value)
                    continue
                
                elif line.startswith(KEY_COMMENT):
                    if DEBUG:
                        print 'Found a comment: %s' % line
                    # This is a comment
                    continue

                elif re.match('^\S', line):
                    # This does not start with whitespace, so it must be a rule
                    if DEBUG:
                        print 'Found a rule: %s' % line,
                    rule = line.rstrip("\n")
                    if not re.search(rule, filename):
                        if DEBUG:
                            print 'Rule %s does not match %s' % (rule, filename)
                        continue

                    matched_rule = rule

                    # Find out what kind of rule this is
                    key_line = fp.readline()
                    indent = re.findall('^(\s+)', key_line)[0]
                    while re.match('^' + indent, key_line):
                        key_line = key_line.strip()
                        if DEBUG:
                            print 'Found %s rule for %s' % (key_line, rule)
                        if key_line == "\n":
                            break
                        elif key_line not in rules_to_run:
                            if DEBUG:
                                print 'Rule %s does not apply to event %d on %s.' % (key_line, event.mask, rule)
                            # Skip the contents of this rule
                            key_line = fp.readline()
                            while re.match('^'+indent+indent, key_line):
                                key_line = fp.readline()
                            continue

                        last_pos = fp.tell()
                        rule_line = fp.readline()
                        rule_contents = []
                        while re.match('^'+indent+indent, rule_line) and rule_line != "\n":
                            rule_contents.append(rule_line.strip())
                            last_pos = fp.tell()
                            rule_line = fp.readline()

                        # Combine the given commands into one line using ands so that one failure makes everything stop
                        commands = ' && '.join(rule_contents)
                        if DEBUG:
                            print "Rule contents are:\n%s" % commands

                    continue

                elif line == '' or not line:
                    if DEBUG:
                        print 'Done parsing file.'
                    break

        if matched_rule is None:
            print 'No matching rule found for %s.' % filename
            return
        elif DEBUG:
            print 'Matched rule %s for %s' % (matched_rule, filename)

        # Check the changed filename against each of the regexes from the settings file
        match = re.search(matched_rule, filename)
        # Create a dict that maps the group numbers to their matched values
        groups = match.groups()
        match_groups = {str(i + 1): groups[i] for i in xrange(len(groups))}

        # Replace autobuild variables $0, $1, $2, etc with Python-esqe $(0)s, $(1)s, etc and use that to pass matched groups in
        match_groups['0'] = relpath(event.name, settings_dir)
        commands = re.sub('\$\{([0-9]+)\}', '%(\\1)s', re.sub('\$([0-9]+)', '%(\\1)s', commands)) % match_groups

        # Add the inherited ZEnv variables
        inherited_envs = '; '.join('%s=%s' % (i, quote(os.environ[i])) for i in os.environ if i.startswith('ZENV_'))
        # Add variable declarations to the beginning of the commands
        var_decls = '; '.join(envs)
        full_program = '; '.join([inherited_envs, var_decls, commands])

        # Run the command
        print 'Running build for %s' % event.name
        if DEBUG:
            print full_program
        else:
            print commands
        os.system(('cd %s; ' % settings_dir) + full_program)
        print "Build complete.\n"



observer = Observer()
observer.start()
stream = Stream(callback, local_path, file_events=True)
observer.schedule(stream)

def interrupt_handler(signal, frame):
    observer.unschedule(stream)
    observer.stop()
    print 'Thank you, come again.'

signal.signal(signal.SIGINT, interrupt_handler)
signal.pause()
