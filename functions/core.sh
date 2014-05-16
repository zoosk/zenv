#! /usr/bin/env bash

##
# Core functions.

##
# Change the current workspace to be the one specified in $1
#
function use() {
    . zenv_use "$@"
}
export -f use

##
# Exit from ZEnv.
#
function deactivate() {
    echo "Goodbye. ZEnv will miss you while you're gone. :'("
    exit 0
}
