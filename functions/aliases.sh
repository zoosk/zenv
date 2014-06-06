##########################  UTILITY ALIASES  ##########################
# Log into your dev instance
alias devbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its dev instance."; else ssh "${ZENV_LDAP_USERNAME}@${ZENV_DEVSERVER}"; fi'

# Log into your database
alias dbbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its database."; else mysql -h ${ZENV_DBIP} -u root -p$(readprop dev_rootdbpass); fi'


##########################  BATCH BUILD ALIASES  ##########################
# Install not just everything, but everything-everything. Good for new hires and for first time users of their Dev VM
alias initial-setup='(checksystem && build install && build install-and-build-photo-service && install-geodata && build install-and-build-utility-service && build install-test-500)'

# Install everything
alias install-all='(install-most && install-test && install-test-500)'

# Reinstall everything
alias reinstall-all='(delete-all && install-all)'

# Install everything except test data
alias install-most='(build install-tools install-schwartz install-web install-web-test build-thrift-php-interface && buildweb refresh-live-mission-control-data-from-production)'

# Install all geodata
alias install-geodata='(rsync-geodbdata && build install-geoip-data && build install-geolookup-data)'

# Get rid of all the work files (done using ssh for speed)
alias delete-all="(ssh -t \"\$ZENV_LDAP_USERNAME@\$ZENV_DEVSERVER\" \"rm -rf \${ZENV_SERVERDIR}/current/*\" 2>/dev/null)"

# Get rid of all the database info
alias delete-db='(build truncate-all)'


##########################  INDIVIDUAL PROJECT BUILD ALIASES  ##########################
# Install the API code
alias install-api='(buildweb install-web-api)'

# Install the include layer
alias install-inc='(buildweb install-web-include)'

# Install the web CSS
alias install-css='(buildstatic install-css)'

# Install the tools code
alias install-tools='(build upgrade-tools)'

# Install touch
alias install-touch='(buildweb install-web-touch)'

# Install web
alias install-web='(buildweb install-web-www)'

# Install the payment service
alias install-payments='(build install-and-build-payment-service)'

# Install test data
alias install-test='(buildweb install-test)'

# Install test 500
alias install-test-500='(buildweb install-test-500)'

# Rsync geodbdata (required for install-geolookup-data)
alias rsync-geodbdata="mkdir -p ${ZENV_LOCAL_DEPLOY_DIR}/geodbdata && rsync -az --progress ${ZENV_LDAP_USERNAME}@db1qa.sfo2.zoosk.com:/mnt/geodbdata/ ${ZENV_LOCAL_DEPLOY_DIR}/geodbdata/"
