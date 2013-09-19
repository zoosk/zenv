#! /usr/bin/env bash

##
# Build functions
#

##
# Run the build command from the specified folder.
# Usage: build-generic folder args...
#
function buildgeneric() {
    if [ -z "$ZENV_CURRENT_WORK" ]; then
        echoerr 'There is no workspace currently set.'
        return 1
    fi
    local BUILD_DIR="$1"
    if [ ! -d "$BUILD_DIR" ]; then
        echoerr "Cannot build in ${1}: directory does not exist"
        return 1
    fi
    shift  # $* is now the arguments to pass to the build command
    cd $BUILD_DIR
    (eval $ZENV_BUILD_COMMAND $*)
    local RC=$?
    (eval $ZENV_COMPLETE_COMMAND)
    cd - 1>/dev/null
    return $RC
}
export -f buildgeneric

##
# Build a target at the root level
#
function build() {
    buildgeneric "$ZENV_CURRENT_WORK" $*
}
export -f build

##
# Build a target at the web/ level
#
function buildweb() {
    buildgeneric "$ZENV_CURRENT_WORK/web" $*
}
export -f buildweb
alias build-web=buildweb

##
# Build a static target
#
function buildstatic() {
    buildgeneric "${ZENV_CURRENT_WORK}/web/static" $*
}
export -f buildstatic
alias build-static=buildstatic
