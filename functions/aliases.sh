##########################  UTILITY ALIASES  ##########################
# Log into your dev instance
alias devbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its dev instance."; else ssh "${ZENV_LDAP_USERNAME}@${ZENV_DEVSERVER}"; fi'
# Log into your database
alias dbbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its database."; else mysql -h ${ZENV_DBIP} -u root -p$(readprop dev_rootdbpass); fi'
##########################  BATCH BUILD ALIASES  ##########################
# Install not just everything, but everything-everything. Good for new hires and for first time users of their Dev VM
alias initial-setup='(checksystem && build install && build install-and-build-photo-service && build install-photov3-db && install-geodata && build install-test-500)'
# Install everything
alias install-all='(install-most && install-test && install-test-500)'
# Reinstall everything
alias reinstall-all='(delete-all && install-all)'
# Install everything except test data
alias install-most='(build install-tools install-schwartz install-web install-web-test build-thrift-php-interface generate-payment-service-client install-psyche && buildweb refresh-live-mission-control-data-from-production)'
# Install all geodata
alias install-geodata='(rsync-geodbdata && build install-geoip-data && build install-geolookup-data)'
# Get rid of all the work files (done using ssh for speed)
alias delete-all="(rm -rf \${ZENV_SERVERDIR}/* 2>/dev/null && synccode \${ZENV_SERVERDIR})"
# Get rid of all the database info
alias delete-db='(build truncate-all)'

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
alias install-mission-control='(buildweb install-config refresh-live-mission-control-data-from-production)'

# Install the payment service
alias install-payments='(build install-and-build-payment-service)'
# Install test data
alias install-test='(buildweb install-test)'
# Install test 500
alias install-test-500='(buildweb install-test-500)'
# Install test 2k
alias install-test2k='(buildweb install-test2k-fake)'
# Install test 10k
alias install-test10k='(buildweb install-test10k-fake)'

# Rsync geodbdata (required for install-geolookup-data)
alias rsync-geodbdata="mkdir -p ${ZENV_LOCAL_DEPLOY_DIR}/geodbdata && rsync -az --progress ${ZENV_LDAP_USERNAME}@buildmaster.sfo2.zoosk.com:/mnt/geodbdata/ ${ZENV_LOCAL_DEPLOY_DIR}/geodbdata/"
