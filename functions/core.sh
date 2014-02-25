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
            echoerr 'There is no workspace currently set.'
        else
            echo "The current workspace is ${ZENV_CURRENT_WORK}"
        fi
        return 0
    fi

    # Make sure the new workspace exists
    if [ "$(echo "$1" | sed 's/\(.\).*/\1/')" == '/' ]; then
        local NEW_WORK="$1"
    else
        local NEW_WORK="${ZENV_WORKSPACE}/$1"
    fi
    if [ ! -d "$NEW_WORK" ]; then
        echoerr "$NEW_WORK is not a valid workspace."
        return 1
    fi

    # Save old repo type we are changing from
    local NEED_TO_STRIP_OLD="false"
    if [ -n "$ZENV_CURRENT_WORK" ]; then
        local NEED_TO_STRIP_OLD="true"
    fi
    local OLD_REPO_KIND="$(inspect $ZENV_CURRENT_WORK repo_type 2>/dev/null)"

    # Get in there!
    export ZENV_CURRENT_WORK="$NEW_WORK"
    export WORK="$NEW_WORK"  # Backwards compatibility
    cd "$ZENV_CURRENT_WORK"

    # setup path to look for commands specific to repo type
    local REPO_KIND=$(inspect "$PWD" repo_type)
    # if old repo was set, strip its "bin" directory from the path 
    if [ "$NEED_TO_STRIP_OLD" = "true" ]; then
        export PATH=$(echo $PATH|sed -e "s@$ZENV_ROOT/bin/$OLD_REPO_KIND[:]*@@;s/:$//;")
    fi
    # now prepend new repo's "bin" dir to path
    export PATH=$(echo $PATH|sed -e "s|^|$ZENV_ROOT/bin/$REPO_KIND:|")

    # Make sure the workspace is initialized
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


##
# A version of echo that prints to stderr by default.
#
function echoerr() {
    echo "$@" 1>&2
}
export -f echoerr
