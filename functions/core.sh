#! /usr/bin/env bash

##
# Core functions.

##
# Change the current workspace to be the one specified in $1
#
function use() {
    # If nothing is passed, return the current workspace
    if [ -z "$1" ]; then
        if [ -z "$ZENV_CURRENT_WORK" ]; then
            echo 'There is no workspace currently set.'
        else
            echo "The current workspace is ${ZENV_CURRENT_WORK}"
        fi
        return 0
    fi

    # Make sure the new workspace exists
    local NEW_WORK="${ZENV_WORKSPACE}/$1"
    if [ ! -d "$NEW_WORK" ]; then
        echo "$NEW_WORK is not a valid workspace."
        return 1
    fi

    # Get in there!
    export ZENV_CURRENT_WORK="$NEW_WORK"
    cd "$ZENV_CURRENT_WORK"

    # Make sure the workspace is initialized
    source "$ZENV_SETTINGS"
    if [ -e "$ZENV_WORKSPACE_SETTINGS" ]; then
        source "$ZENV_WORKSPACE_SETTINGS"
    else
        echo 'This workspace must be initialized before you use it.'
        work_init
        source "$ZENV_WORKSPACE_SETTINGS"
    fi
    echo "Workspace changed to ${ZENV_CURRENT_WORK}"
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
