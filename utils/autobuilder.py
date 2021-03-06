#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""Utility to build changed, added, or deleted dev files on VM"""

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

# Libraries

import zenvlib
from zenvlib import cli, modules

modules.install_if_needed('watchdog')

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

import os
from os.path import basename
from os.path import dirname
from os.path import exists
from os.path import relpath
from pipes import quote
import time
import re

# Env check
cli.fail_without_workspace()

# Settings
BUILD_SETTINGS_FILE = 'autobuild_settings'
DEBUG = False

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
EXCLUDED_FILE_NAMES = {
    BUILD_SETTINGS_FILE,
    'build.xml',
    'Makefile'
}

# Work paths
LOCAL_PATH = zenvlib.environ.current_work
    # In the future, we may have a need for...
    # SERVER_PATH = os.environ['ZENV_SERVERDIR']


# Check if a file should be excluded from builds
def is_excluded_path(path, file_name):
    """Determine if a path is disallowed from processing"""
    return (
        file_name.startswith('.') or
        file_name.startswith('#') or
        file_name.endswith('~') or
        re.match(r'^\d+$|.*~$', file_name) or
        file_name in EXCLUDED_FILE_NAMES or
        '.svn' in path or
        '.idea' in path or
        '/sass-cache' in path or
        '.git' in path
    )


def process_change(change_type, path):
    """ Utility to sync vm when a file is changed. """
    if DEBUG:
        print 'Change type |%s| reported for path |%s|' % (change_type, path)

    if not re.match('modified|created|deleted', change_type):
        if DEBUG:
            print '    - skipped: change type |%s| not supported' % change_type
        return

    file_name = basename(path)
    if is_excluded_path(path, file_name):
        if DEBUG:
            print '    - skipped: path pattern |%s| is excluded' % path
        return

    # Travel up the directory structure until we find one
    # with a settings file in it
    #
    extra_dirs = []
    settings_dir = dirname(path)
    while not exists(settings_dir + '/' + BUILD_SETTINGS_FILE) and settings_dir != '/':
        extra_dirs.insert(0, basename(settings_dir) + '/')
        settings_dir = dirname(settings_dir)

    if DEBUG:
        print 'Directory with settings file is |%s|' % settings_dir

    if settings_dir == '/':
        # This is certainly not a workspace
        print 'Could not find a settings file appropriate for %s.' % path
        return

    # Get the kind of rules_to_run that we are looking for
    if change_type == 'modified':
        rules_to_run = {KEY_ALL, KEY_UPDATE, KEY_ADDUP, KEY_UPDEL}
    elif change_type == 'created':
        rules_to_run = {KEY_ALL, KEY_ADD, KEY_ADDUP, KEY_ADDDEL}
    elif change_type == 'deleted':
        rules_to_run = {KEY_ALL, KEY_DELETE, KEY_ADDDEL, KEY_UPDEL}
    else:
        print 'OH GOD AN UNHANDLED CHANGE TYPE'
        return

    # Get the contents of the settings file
    matched_rule = None
    commands = None
    envs = []

    with open(settings_dir + '/' + BUILD_SETTINGS_FILE) as file_ptr:
        while matched_rule is None:
            line = file_ptr.readline()

            # Read the variable settings
            if line.startswith(KEY_SET):
                env_name, env_value = (
                    re.search('%s ([^=]+)=(.*)' % KEY_SET, line).groups()
                )

                envs.append('%s=%s' % (env_name, env_value))
                if DEBUG:
                    print ('Found variable declaration |%s| = |%s|' % (env_name, env_value))
                continue

            elif line.startswith(KEY_COMMENT):
                # This is a comment (wow, so meta!)
                if DEBUG:
                    print 'Found comment |%s|' % line
                continue

            elif re.match(r'^\S', line):
                # This does not start with whitespace, so it must be a rule
                if DEBUG:
                    print 'Found rule |%s|' % line,
                rule = line.rstrip("\n")
                if not re.search(rule, file_name):
                    if DEBUG:
                        print ('Rule |%s| does not match file |%s|' % (rule, file_name))
                    continue

                matched_rule = rule

                # Find out what kind of rule this is
                key_line = file_ptr.readline()
                indent = re.findall(r'^(\s+)', key_line)[0]

                while re.match('^' + indent, key_line):
                    key_line = key_line.strip()
                    if DEBUG:
                        print 'Found key |%s| for rule |%s|' % (key_line, rule)
                    if key_line == "\n":
                        break
                    elif key_line not in rules_to_run:
                        if DEBUG:
                            print (
                                'Rule |{sr}| does not apply to ' +
                                'change |{sc}| on key |{sk}|'.format(
                                    sr='' if not rule else rule,
                                    sk='' if not key_line else key_line,
                                    sc='' if not change_type else change_type
                                )
                            )

                        # Skip the contents of this rule
                        key_line = file_ptr.readline()
                        while re.match('^' + indent + indent, key_line):
                            key_line = file_ptr.readline()
                        continue

                    # last postion is file_ptr.tell()
                    rule_line = file_ptr.readline()
                    rule_contents = []
                    while re.match('^' + indent + indent, rule_line) and rule_line != "\n":
                        rule_contents.append(rule_line.strip())
                        # last postion is file_ptr.tell()
                        rule_line = file_ptr.readline()

                    # Combine the given commands into one line using
                    # so that one failure makes everything stop
                    #
                    commands = ' && '.join(rule_contents)
                    if DEBUG:
                        print "Rule contents are:\n%s" % commands

                continue

            elif line == '' or not line:
                if DEBUG:
                    print 'Done parsing file.'
                break

        if matched_rule is None:
            print 'No matching rule found for file |%s|.' % file_name
            return
        elif DEBUG:
            print ('Matched rule |%s| for file |%s|' % (matched_rule, file_name))

        # Check the changed file_name against each of the regexes from
        # the settings file
        match = re.search(matched_rule, file_name)

        # Create a dict that maps the group numbers to their matched values
        groups = match.groups()
        match_groups = {str(i + 1): groups[i] for i in xrange(len(groups))}

        # Replace autobuild variables $0, $1, $2, etc with
        # Python-esqe $(0)s, $(1)s, etc and use that to pass matched groups
        match_groups['0'] = relpath(path, settings_dir)
        commands = re.sub(r'\$\{([0-9]+)\}', '%(\\1)s',
            re.sub(r'\$([0-9]+)', '%(\\1)s', commands)) % match_groups

        # Add the inherited ZEnv variables
        inherited_envs = '; '.join('%s=%s' %
            (i, quote(os.environ[i]))
            for i in os.environ if i.startswith('ZENV_')
        )

        # Add variable declarations to the beginning of the commands
        var_decls = '; '.join(envs)
        full_program = '; '.join([inherited_envs, var_decls, commands])

        # Run the command
        print 'Running build for path |%s|' % path
        if DEBUG:
            print full_program
        else:
            print commands
        os.system(('cd %s; ' % settings_dir) + full_program)
        print "Build complete.\n"


def on_changed(event):
    """Handle handler for fsevents.
    This is separate from process_change so that may be used independently.
    """

    path = event.src_path
    change_type = event.event_type
    class_name = event.__class__.__name__
    if re.match('^Dir', class_name):
        if DEBUG:
            print '    - skipped dir |%s|' %(path)
            return

    return process_change(change_type, path)


if __name__ == '__main__':
    OBSERVER = Observer()
    EVENT_HANDLER = FileSystemEventHandler()
    EVENT_HANDLER.on_created = on_changed
    EVENT_HANDLER.on_modified = on_changed
    EVENT_HANDLER.on_deleted = on_changed

    ## The following event types are not supported
    # EVENT_HANDLER.on_moved     = on_changed
    # EVENT_HANDLER.on_any_event = on_changed

    OBSERVER.schedule(EVENT_HANDLER, LOCAL_PATH, recursive=True)
    OBSERVER.start()

    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        OBSERVER.stop()

    OBSERVER.join()