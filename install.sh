#! /usr/bin/env bash

##
# This is the installation file for ZEnv. It will create the ~/.zenvrc file with all of the user's settings
# defined in it.
#

# Ensure that everything is being run from the correct directory
if [ ! -e "$0" ]; then
    # $0 is just the name of the script; if it is not in this directory we can't use any pathing info and must quit
    echo 'Please run the install script from the directory containing it.'
    exit 1
fi

# The path to the ZEnv root. This works 99% of the time(?)
ZENV_ROOT="$( cd "$(dirname "$0")" && pwd -P)"

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

ZENV_LDAP_USERNAME=$(whoami)
read -p "Enter your LDAP username (${ZENV_LDAP_USERNAME}): " TEMP
if [ "$TEMP" != '' ]; then
    ZENV_LDAP_USERNAME="$TEMP"
fi

ZENV_WORKSPACE="${HOME}/dev/workspace"
read -p "Enter the path to your workspace folder, where you store your checkouts (${ZENV_WORKSPACE}): " TEMP
if [ "$TEMP" != '' ]; then
    ZENV_WORKSPACE="$TEMP"
fi
if [ ! -e "$ZENV_WORKSPACE" ]; then
    mkdir -p "$ZENV_WORKSPACE"
fi

# Give the option to install MacFSEvents, as the autobuilder requires it
if [ "$(which clang)" != '' -a "$(python -c 'import watchdog' 2>/dev/null; echo $?)" == '1' ]; then
    read -p 'You need to have watchdog installed if you want to use the automatic builder. Would you like to install it now [y/n] (y)? ' TEMP
    if [ "$TEMP" != 'n' ]; then
        if [ "$(which pip)" == '' ]; then
            sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future easy_install watchdog
        else
            sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future pip install watchdog
        fi
    fi
fi

ZENV_LOCAL_DEPLOY_DIR="/srv"
if [ ! -e "${ZENV_LOCAL_DEPLOY_DIR}" ]; then
    echo "Creating local deploy dir (${ZENV_LOCAL_DEPLOY_DIR}). You may be asked for your local sudo password."
    sudo mkdir -p ${ZENV_LOCAL_DEPLOY_DIR}
    USER="$(whoami)"
    sudo chown -R "$USER" "${ZENV_LOCAL_DEPLOY_DIR}"
fi

checkWritable() {
    touch "$1"/zenv_touched 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Your ${1} directory is not writable. If prompted, please enter your password below to fix this."
        USER="$(whoami)"
        sudo mkdir -p "$1"
        sudo chown -R "$USER" "$1"
    fi
    rm -f "$1"/zenv_touched 2>/dev/null
}
checkWritable "$ZENV_LOCAL_DEPLOY_DIR"
checkWritable "$ZENV_LOCAL_DEPLOY_DIR"/geodbdata
# Make sure the deploy dir is writable

echo 'Installing...'

# Generate the setup file
echo "#! /usr/bin/env bash

######
## This is the global ZEnv settings file. If you want to change your global configuration without
## reinstalling everything, just modify the values in this file and then start a new terminal.
######

# The path to the ZEnv directory.
export ZENV_ROOT=${ZENV_ROOT}

# The location of this file.
export ZENV_SETTINGS=${ZENV_SETTINGS}

# The workspace containing all your checkouts.
export ZENV_WORKSPACE=${ZENV_WORKSPACE}

# The command that will run after builds complete successfully.
export ZENV_COMPLETE_COMMAND='notify -title \"\$(basename \"\${ZENV_CURRENT_WORK}\")\" -message \"Build complete!\" >/dev/null'

# The command that will run if a build fails.
export ZENV_FAILED_COMMAND='notify -title \"\$(basename \"\${ZENV_CURRENT_WORK}\")\" -message \"Build failed!\" >/dev/null'

# Your LDAP username, that is, what you use to login to your Dev server
export ZENV_LDAP_USERNAME=\"${ZENV_LDAP_USERNAME}\"

# Local folder where your projects are built to, before being rsync'd to your VM
export ZENV_LOCAL_DEPLOY_DIR=\"${ZENV_LOCAL_DEPLOY_DIR}\"


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
touch ~/.bash_login
if [ "$(egrep '^alias zenv=.*activate.sh$' ~/.bash_login)" == '' ]; then
    echo "alias zenv=${ZENV_ROOT}/activate.sh" >> ~/.bash_login
else
    perl -pi -e "s?alias zenv=.*?alias zenv=${ZENV_ROOT}/activate.sh?" ~/.bash_login
fi

# Remove all the old work init files just in case something has changed
WORKPROP_STR=$(\
  find "${ZENV_WORKSPACE}" -maxdepth 5 -type f -name 'work.properties' \
  | xargs grep -l ZENV\
)
if [ "${WORKPROP_STR}" != "" ]; then rm ${WORKPROP_STR}; fi

# Attempt to make ZEnv start by default
touch ~/.bash_login
if [ "$(egrep 'source .*\.zenvrc' ~/.bash_login)" == '' ]; then
    read -p 'Would you like to set ZEnv as your default shell [y/n] (y)? ' TEMP
    if [ "$TEMP" != 'n' ]; then
	echo "### BEGIN ZENV INIT
source '${ZENV_SETTINGS}'
if [ -z \"\$ZENV_CURRENT_WORK\" -a -n \"\$(grep -m 1 ZENV \"\$ZENV_WORKSPACE_SETTINGS\" 2>/dev/null)\" ]; then
    use \$(python -c \"from os import path; print path.relpath('\${PWD}', '\${ZENV_WORKSPACE}')\")
fi
### END ZENV INIT
" >> ~/.bash_login
    else
	echo 'You can start ZEnv at any time by typing "zenv".'
    fi
fi

echo "${RED}${BOLD}<3${TXTRESET} ${BOLD}Setup is now complete! Restart your terminal and 'use' a checkout to begin using ZEnv.${TXTRESET}"
