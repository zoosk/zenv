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

ZENV_DEVID="$DEVID"  # Pick this up from the old build system
read -p "Enter your dev ID (${ZENV_DEVID}): " TEMP
if [ "$TEMP" != '' ]; then
    ZENV_DEVID=$TEMP
fi
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

if [ "$(which clang)" != '' -a "$(python -c 'import fsevents' 2>/dev/null; echo $?)" == '1' ]; then
    read -p 'You need to have MacFSEvents installed if you want to use the automatic builder. Would you like to install it now [y/n] (y)? ' TEMP
    if [ "$TEMP" != 'n' ]; then
        if [ "$(which pip)" == '' ]; then
            sudo easy_install macfsevents
        else
            sudo pip install macfsevents
        fi
    fi
fi

echo 'Installing...'

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

# The command that will run after builds complete successfully.
export ZENV_COMPLETE_COMMAND='notify -title \"\$(basename \"\${ZENV_CURRENT_WORK}\")\" -message \"Build complete!\" >/dev/null'

# The command that will run if a build fails.
export ZENV_FAILED_COMMAND='notify -title \"\$(basename \"\${ZENV_CURRENT_WORK}\")\" -message \"Build failed!\" >/dev/null'

############################## Anything below this line SHOULD NOT BE EDITED!!! ##############################

export PATH=\"\${ZENV_ROOT}/bin:\$PATH\"
for i in \$(find \${ZENV_ROOT}/functions -name '*.sh'); do
    source \$i
done

export ZENV_INITIALIZED=1
" > "$ZENV_SETTINGS"

# Load all the properties from the .rc file
source "$ZENV_SETTINGS"

# Create the command alias so zenv can be run
if [ "$(egrep '^alias zenv=.*activate.sh$' ~/.bash_login)" == '' ]; then
    echo "alias zenv=${ZENV_ROOT}/activate.sh" >> ~/.bash_login
else
    sed -i '' "s|alias zenv=.*|alias zenv=${ZENV_ROOT}/activate.sh|" ~/.bash_login
fi

# Remove all the old work init files just in case something has changed
find ~/dev/workspace -name work.properties -maxdepth 5 | xargs grep -l ZENV | xargs rm

# Attempt to make ZEnv start by default
if [ "$(egrep 'source .*\\.zenvrc' ~/.bash_login)" == '' ]; then
    read -p 'Would you like to set ZEnv as your default shell [y/n] (y)? ' TEMP
    if [ "$TEMP" != 'n' ]; then
        echo "source '${ZENV_SETTINGS}'
if [ -z \"\$ZENV_CURRENT_WORK\" -a -n \"\$(grep -m 1 ZENV \"\$ZENV_WORKSPACE_SETTINGS\" 2>/dev/null)\" ]; then 
    use \$(python -c \"from os import path; print path.relpath('\${PWD}', '\${ZENV_WORKSPACE}')\")
fi
" >> ~/.bash_login
    else
        echo 'You can start ZEnv at any time by typing "zenv".'
    fi
fi

read -p 'Would you like to create a workspace now [y/n]? ' TEMP
if [ "$TEMP" == 'y' ]; then
    read -p 'Enter the name of the folder containing your checkout: ' TEMP
    cd "${ZENV_WORKSPACE}/${TEMP}"
    work_init
fi

echo 'Setup complete!'
