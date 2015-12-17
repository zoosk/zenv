#! /usr/bin/env bash

source "${ZENV_ROOT}/setupscripts/default.setup.sh"

##
# Update the zoosk core properties file.
#
function update_properties() {

    if [ -e "$ZENV_BUILDPROPS" ]; then
        if [ $ZENV_DEVID -lt 10 ]; then
            NUMBERPAD='0'
        else
            NUMBERPAD=''
        fi

        if [ "$(grep devid_padded= "$ZENV_BUILDPROPS")" == '' ]; then
            sed -e 's/^devid=.*/devid='${ZENV_DEVID}'\
devid_padded='${ZENV_DEVID_PADDED}'/' \
            -i '' "$ZENV_BUILDPROPS"
        fi

        sed -e "s/^devid=.*/devid=${ZENV_DEVID}/" \
        -e "s/^dbprefix=.*/dbprefix=${NUMBERPAD}\${devid}/" \
        -e "s/^memcache_port=.*/memcache_port=$(($ZENV_DEVID % 10))/" \
        -e "s/^dev_hostip=.*/dev_hostip=$(host ${ZENV_DEVSERVER} | awk '{print $4}')/" \
        -e "s/^dev_hostname=.*/dev_hostname=${ZENV_DEVSERVER}/" \
        -e "s/^dev_dbhostip=.*/dev_dbhostip=${ZENV_DBIP}/" \
        -e "s/^dev_aws_secret_access_key=\$/dev_aws_secret_access_key=C7eDlLbtQ8fiIXseo69g3aeOXZf7QzsyxnpMTQWy/" \
        -e "s/^dev_offerpal_api_secret=\$/dev_offerpal_api_secret=1830806557011586/" \
        -e "s/^dev_rootdbpass=\$/dev_rootdbpass=nwN9vrsbzl@vdc4f/" \
        -e "s/^dev_saftpay_api_secret=\$/dev_saftpay_api_secret=347ae91d1bac4d4a88760ca1d875b9cf/" \
        -e "s/^dev_iovation_dra_password=\$/dev_iovation_dra_password=86TNJS89S/" \
        -e "s/^dev_recatpcha_api_secret=\$/dev_recatpcha_api_secret=6Ld0CAQAAAAAALe6IDgE8F0skZAhNVg81EGO7Mni/" \
        -e "s/^dev_syniverseftpusername=\$/dev_syniverseftpusername=pickuser/" \
        -e "s/^dev_syniverseftppassword=\$/dev_syniverseftppassword=S\&F#T9P/" \
        -e "s/^dev_test_email=\$/dev_test_email=$(whoami)@zoosk.com/" \
        -e "s/^dev_tigasebuildno=\$/dev_tigasebuildno=0.0.0.0/" \
        -e "s/^dev_chatbuildno=\$/dev_chatbuildno=0.0.0.\${devid}/" \
        -e "s/^devid_padded=.*/devid_padded=${ZENV_DEVID_PADDED}/" \
        -e "s/^dev_serverid=.*/dev_serverid=/" \
        -e "s/^dev_chat_port=.*/dev_chat_port=5222/" \
        -e "s/^dev_bosh_port=.*/dev_bosh_port=5280/" \
        -e "s/^dev_bosh_ssl_port=.*/dev_bosh_ssl_port=5281/" \
        -i '' "$ZENV_BUILDPROPS"
    fi
}

if [ ! -e "$ZENV_BUILDPROPS" ]; then
    read -p "It doesn't look like you have a developer-specific vmdev properties file. Would you like to make one [y/n] (y)? " TEMP
    if [ "$TEMP" != 'n' ]; then
        read -p "Do you have an old-style non-VM properties file that you used for dev instances [y/n] (n)? " TEMP
        if [ "$TEMP" == 'y' ]; then
            ZENV_OLD_DEVNN_PROPS_FILE=${ZENV_WORKSPACE}/dev${ZENV_DEVID}.properties
            read -p "Where is your existing dev${ZENV_DEVID}.properties (${ZENV_OLD_DEVNN_PROPS_FILE})? " TEMP
            if [ "$TEMP" != '' ]; then
                ZENV_OLD_DEVNN_PROPS_FILE="$TEMP"
            fi
            cp ${ZENV_OLD_DEVNN_PROPS_FILE} $ZENV_BUILDPROPS
        else
            # Use the default one that's checked into core
            cp dev.properties "$ZENV_BUILDPROPS"
        fi

        sed -e "s/^devid=.*/devid=${ZENV_DEVID}/" \
            -e "s/^devid_padded=.*/devid_padded=${ZENV_DEVID_PADDED}/" \
            -e "s/^dev_serverid=.*/dev_serverid=/" \
            -e "s/^dev_chat_port=.*/dev_chat_port=5222/" \
            -e "s/^dev_bosh_port=.*/dev_bosh_port=5280/" \
            -e "s/^dev_bosh_ssl_port=.*/dev_bosh_ssl_port=5281/" \
            -i '' "$ZENV_BUILDPROPS"
    fi
fi

update_properties
