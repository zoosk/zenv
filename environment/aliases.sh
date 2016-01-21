##########################  UTILITY ALIASES  ##########################
# Log into your database
alias dbbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its database."; else mysql -h ${ZENV_DBIP} -u root -p$(readprop dev_rootdbpass); fi'
##########################  BATCH BUILD ALIASES  ##########################
##
## IMPORTANT NOTE: do not add logic to these aliases!
## Logic belongs in the build files themselves (otherwise changing logic relies on devs calling update_zenv)
## Aliases should only call 1 build target (but can also call other non-build stuff)
##
###########################################################################

# Install not just everything, but everything-everything. Good for new hires and for first time users of their Dev VM
alias initial-setup='(checksystem && build install && build install-and-build-photo-service && build install-photov3-db && install-geodata && build install-test1k)'
# Refresh Mission Control
alias refresh-mc='(buildweb refresh-live-mission-control-data-from-production)'
# Install everything
alias install-all='(build install-all && refresh-mc && clearmem)'
# Reinstall everything
alias reinstall-all='(delete-all && install-all)'
# Install everything except test data
alias install-most='(build install-most)'
# Install all geodata
alias install-geodata='(rsync-geodbdata && build install-geo-data)'
# Get rid of all the work files (done using ssh for speed)
alias delete-all='(if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to delete its files."; else rm -rf ${ZENV_SERVERDIR}/* 2>/dev/null && synccode ${ZENV_SERVERDIR}; fi)'
# Get rid of all the database info [we need to run this on the dev vm]
alias delete-db='(testscript data/truncate_all.php --batch)'

##########################  INDIVIDUAL PROJECT BUILD ALIASES  ##########################
# Install the API code
alias install-api='(buildweb install-web-api)'
# Install the include layer
alias install-inc='(buildweb install-web-include)'
# Install the web CSS
alias install-css='(buildstatic install-css)'
# Install the web JS
alias install-js='(buildstatic install-js)'

# Install the tools code
alias install-tools='(build upgrade-tools)'
# Install touch
alias install-touch='(buildweb install-web-touch)'
# Install web
alias install-web='(buildweb install-web-www)'
# Install admin layer
alias install-admin='(buildweb install-web-admin)'

# Install the web autoloader classes
alias install-autoloaders='(buildweb install-autoloaders)'

# Install the mission control
alias install-mission-control='(buildweb install-mission-control)'

# Install the payment service
alias install-payments='(build install-and-build-payment-service)'
# Install test data
alias install-test='(build install-web-test)'
# Install test 1k
alias install-test1k='(builddev install-test1k)'
# Install test 10k
alias install-test10k='(build install-test10k-fake)'

# Rsync geodbdata (required for install-geolookup-data)
alias rsync-geodbdata="mkdir -p ${ZENV_LOCAL_DEPLOY_DIR}/geodbdata && rsync -az --progress ${ZENV_LDAP_USERNAME}@buildmaster.sfo2.zoosk.com:/mnt/geodbdata/ ${ZENV_LOCAL_DEPLOY_DIR}/geodbdata/"

# Rsync pipeline
alias rsync-pipeline="mkdir -p /srv/dev${ZENV_DEVID}_pipeline/current && rsync -rql . /srv/dev${ZENV_DEVID}_pipeline/current/. && chmod -R 777 /srv/dev${ZENV_DEVID}_pipeline/current/ && rsync -rql /srv/dev${ZENV_DEVID}_pipeline/current/. \$(readprop PIPELINE_DEV_MACHINE):/srv/pipeline/current/"

