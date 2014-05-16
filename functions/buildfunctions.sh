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
    
    # Rsync the result if: 1) build succeeded, 2) build wasn't run with -l or empty parameter.
    if [ "$RC" -eq 0 ]; then
        if [ "${1:0:1}" != "-" -a ! -z "$1" ]; then
            synccode
        fi
    fi

    if [ $RC -eq 0 ]; then
        (eval $ZENV_COMPLETE_COMMAND)
    else
        (eval $ZENV_FAILED_COMMAND)
    fi
    
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
    if [ -e "$ZENV_CURRENT_WORK/web" ]; then
        buildgeneric "$ZENV_CURRENT_WORK/web" $*
    else
        echoerr 'This checkout does not have a web folder to build.'
    fi
}
export -f buildweb
alias build-web=buildweb

##
# Build a static target
#
function buildstatic() {
    if [ -e "${ZENV_CURRENT_WORK}/web/static" ]; then
        buildgeneric "${ZENV_CURRENT_WORK}/web/static" $*
    else
        echoerr 'THis checkout does not have a static folder to build.'
    fi
}
export -f buildstatic
alias build-static=buildstatic
