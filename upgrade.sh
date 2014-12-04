#!/bin/bash

set -e

source functions/all.sh

log "Welcome to Gitorious upgrader!"
log "This script will update Gitorious installation on this machine to $gitorious_version."
echo
log "It will first shutdown all Gitorious processes and then apply the upgrade steps."
log "Hit <Enter> to continue."
read

log "Shutting down old services..."
shutdown-old-services

log "Backing up old configuration..."
backup-configuration
remove-old-ruby-install

echo
trap 'handle-exit' TERM EXIT
install_gitorious upgrade
success=1

update-old-ctl-scripts

echo
log "Upgrade of your Gitorious installation is complete."
log "Open https://$gitorious_host/ in your browser to start."
echo

log "Old configuration files have been backed up and placed at the following paths:"
echo "  /var/www/gitorious/app/config/gitorious.yml.$backup_ext"
echo "  /var/www/gitorious/app/config/authentication.yml.$backup_ext"
echo "  /var/www/gitorious/app/config/unicorn.rb.$backup_ext"
echo "  /etc/nginx/nginx.conf.$backup_ext"
echo "  /etc/nginx/conf.d/gitorious.conf.$backup_ext"
log "If you have modified any of these after previous installation please apply your changes to the new files and restart Gitorious with 'gitoriousctl restart'"

echo
footnote
