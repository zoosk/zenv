#! /usr/bin/env bash

##
# Core functions.

##
# Change the current workspace to be the one specified in $1
#
function use() {
    if [ -z "$1" ]; then
        if [ -z "$ZENV_CURRENT_WORK" ]; then
            echo 'There is no workspace currently set.'
        else
            echo "The current workspace is ${ZENV_CURRENT_WORK}"
        fi
        return 0
    fi
    local NEW_WORK="${ZENV_WORKSPACE}/$1"
    if [ ! -d "$NEW_WORK" ]; then
        echo "$NEW_WORK is not a valid workspace."
        return 1
    fi
    if [ -e "${NEW_WORK}/work.properties" ]; then
        source "${NEW_WORK}/work.properties"
    fi
    export ZENV_CURRENT_WORK="$NEW_WORK"
    echo "Workspace changed to ${ZENV_CURRENT_WORK}"
    cd "$ZENV_CURRENT_WORK"
}
export -f use


##
# Deactivate the virtual environment, restoring all functions and variables
#
function deactivate() {
    echo "Goodbye. ZEnv will miss you while you're gone. :'("
    exit 0
}
export -f deactivate
