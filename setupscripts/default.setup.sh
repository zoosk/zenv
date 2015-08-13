#! /usr/bin/env bash

# This script will run on initialization of a new checkout, after the
# work.properties file has been created. If it exits successfully, the setup
# will be considered a success.

# For setup behavior specific to a given checkout type, create a script in this
# directory named <checkout_type>.setup.sh. For example, if my repo was named
# 'zoosk', I would create a file called 'zoosk.setup.sh'.

read -p 'Many commands require a connection to your dev instance. Would you like to set up an SSH key to log in without a password [y/n] (n)? ' TEMP
if [ "$TEMP" == 'y' ]; then
    if [ ! -e ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
    fi
    echo 'If prompted, please enter your password to log into your dev instance (for the last time).'
    ssh "${ZENV_LDAP_USERNAME}@$ZENV_DEVSERVER" "mkdir -p .ssh; echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys"
fi

if [ ! -L "${ZENV_LOCAL_DEPLOY_DIR}/zoosk/current" ]; then
  echo "Creating symlink /srv/zoosk/current pointing to ${ZENV_LOCAL_DEPLOY_DIR}/zoosk/releases/${ZENV_DEVID}"
  rm -rf "${ZENV_LOCAL_DEPLOY_DIR}/zoosk/current"
  ln -sf "${ZENV_LOCAL_DEPLOY_DIR}/zoosk/releases/${ZENV_DEVID} ${ZENV_LOCAL_DEPLOY_DIR}/zoosk/current"
fi
