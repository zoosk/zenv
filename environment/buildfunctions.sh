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
    
    "${ZENV_ROOT}/bin/build" $*

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
# Build a dev target
#
function builddev(){
    buildgeneric "$ZENV_CURRENT_WORK" -f build_dev.xml $*
}
export -f builddev
alias build-dev=builddev

##
# Build a data target
#
function builddata(){
    buildgeneric "$ZENV_CURRENT_WORK" -f build_data.xml $*
}
export -f builddata
alias build-data=builddata

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
