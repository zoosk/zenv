#! /usr/bin/env bash

##
# This is the installation file for ZEnv. It will create the ~/.zenvrc file with all of the user's settings
# defined in it.
#

# Ensure that everything is being run from the correct directory
if [ "$(basename $0)" != "$0" ]; then
    # This script was run using a path; we should cd to the directory that it's in
    cd $(dirname $0)
elif [ ! -e "$0" ]; then
    # $0 is just the name of the script; if it is not in this directory we can't use any pathing info and must quit
    echo 'Please run the install script from the directory containing it.'
    exit 1
fi

# The path to the ZEnv root
ZENV_ROOT="$PWD"

if [ "$ZENV_INITIALIZED" != '' ]; then
    echo 'Please exit ZEnv before reinstalling it.'
    exit 1
fi

# Where we get settings
ZENV_SETTINGS="${HOME}/.zenvrc"

# Check before overwriting
if [ -e "$ZENV_SETTINGS" ]; then
    read -p 'You have already installed ZEnv; would you like to reinstall [y/n]? ' TEMP
    if [ "$TEMP" != 'y' ]; then
        exit 0
    fi
fi


echo 'Hello and welcome to Zoosk. Please answer some questions to help set up your dev environment.'
echo "Questions will be presented with default answers in parens. Just hit enter if you don't want to change them."

ZENV_WORKSPACE="${HOME}/dev/workspace"
read -p "Enter the path to your workspace folder, where you store your checkouts (${ZENV_WORKSPACE}): " TEMP
if [ "$TEMP" != '' ]; then
    ZENV_WORKSPACE="$TEMP"
fi
if [ ! -e "$ZENV_WORKSPACE" ]; then
    mkdir -p "$ZENV_WORKSPACE"
fi

read -p "Enter your dev ID: " ZENV_DEVID
if [ ! "$ZENV_DEVID" -eq "$ZENV_DEVID" ]; then
    echo 'You must enter a number for your dev id.'
    return 1
fi

ZENV_SERVERID=$(($ZENV_DEVID / 10 + 1))
read -p "Enter your dev server number (${ZENV_SERVERID}):" TEMP
if [ "$TEMP" != '' ]; then
    if [ ! "$TEMP" -eq "$TEMP" ]; then
        echo 'Your dev server number must be a number.'
        return 1
    else
        ZENV_SERVERID="$TEMP"
    fi
fi

# Generate the setup file
echo "#! /usr/bin/env bash
# The path to the ZEnv directory.
export ZENV_ROOT=${ZENV_ROOT}

# The location of this file.
export ZENV_SETTINGS=${ZENV_SETTINGS}

# The workspace containing all your checkouts.
export ZENV_WORKSPACE=${ZENV_WORKSPACE}

# Your dev id
export ZENV_DEVID=${ZENV_DEVID}

# The ID of your dev instance.
export ZENV_SERVERID=${ZENV_SERVERID}

# The command that will be used to build your code. Arguments are appended.
alias ZENV_BUILD_COMMAND=\"phing -logger phing.listener.DefaultLogger -Dpf1=\\\${ZENV_BUILDPROPS} -Dpf2=\\\${ZENV_CURRENT_WORK}/zooskdev.properties\"

# An optional command that will run after builds complete. For example, 'osascript -e \"beep 3\"'
alias ZENV_COMPLETE_COMMAND=

############################## Anything below this line SHOULD NOT BE EDITED!!! ##############################

export PATH=\"\${ZENV_ROOT}/bin:\$PATH\"
FUNC_FILES=
for i in \$(find \${ZENV_ROOT}/functions -name '*.sh'); do
    source \$i
done

export ZENV_INITIALIZED=1
" > "$ZENV_SETTINGS"

# Load all the properties from the .rc file
source "$ZENV_SETTINGS"

read -p 'Would you like to create a workspace now [y/n]? ' TEMP
if [ "$TEMP" == 'y' ]; then
    read -p 'Enter the name of the folder containing your checkout: ' TEMP
    cd "${ZENV_WORKSPACE}/${TEMP}"
    work_init
fi

echo "echo 'Welcome to ZEnv.'" >> "$ZENV_SETTINGS"
echo 'Setup complete!'
