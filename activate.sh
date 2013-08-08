#! /usr/bin/env bash

if [ "$ZENV_INITIALIZED" == 1 ]; then
    echo 'You are already using ZEnv.'
    exit 1
fi

if [ ! -e ~/.zenvrc ]; then
    echo 'You must install ZEnv before activating it. Run the install.sh script in your checkout.'
    exit 1
fi

# Build the subshell init out of your current bash login file and the ZEnv settings file, adding an auto-workspace init
INIT="$(cat ~/.bash_login)
$(cat ~/.zenvrc)
trap deactivate EXIT
echo \"Welcome to ZEnv. \${RED}<3\${TXTRESET}\"
if [ -n \"\$(grep -m 1 ZENV \"\$ZENV_WORKSPACE_SETTINGS\" 2>/dev/null)\" ]; then 
    use \$(python -c \"from os import path; print path.relpath('\${PWD}', '\${ZENV_WORKSPACE}')\")
fi
"

# Start the subshell using the INIT variable
bash --rcfile <(echo "$INIT")
