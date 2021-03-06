#! /usr/bin/env bash

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

##
# Core functions. These are included here as functions because they need to modify
# the user's environment; do not place utilities here.
#

##
# Change the current checkout to be the one specified in $1
#
function use() {
    . "${ZENV_ROOT}/bin/use" "$@"
}
export -f use

##
# Exit from ZEnv.
#
function deactivate() {
    echo "Goodbye. ZEnv will miss you while you're gone. :'("
    exit 0
}

##
# Uninstall ZEnv.
#
function uninstall_zenv() {
    local STARTUP_FILE="${HOME}/.bash_profile"
    if [ ! -e "$STARTUP_FILE" ]; then
        STARTUP_FILE="${HOME}/.bash_login"
    fi
    if [ ! -e "$STARTUP_FILE" ]; then
        STARTUP_FILE="${HOME}/.profile"
    fi
    if [ ! -e "$STARTUP_FILE" ]; then
        echo 'Could not determine where your settings are stored.'
        return 1
    fi

    read -p 'This will delete all your checkout configuration. Are you sure you want to continue [y/n]? ' TEMP
    if [ "$TEMP" == 'y' ]; then
        if [ "$ZENV_PLATFORM" == 'osx' ]; then
            sed -i '' '/### BEGIN ZENV INIT/,/### END ZENV INIT/d' "$STARTUP_FILE"
            sed -i '' '/^alias zenv/d' "$STARTUP_FILE"
        else
            sed -i '/### BEGIN ZENV INIT/,/### END ZENV INIT/d' "$STARTUP_FILE"
            sed -i '/^alias zenv/d' "$STARTUP_FILE"
        fi

        rm -f "$ZENV_SETTINGS"
        echo "${RED}${BOLD}</3${TXTRESET} ZEnv has been uninstalled."
        exit 0
    fi
}
