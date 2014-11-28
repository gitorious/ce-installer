#!/bin/bash

set -e

source functions/all.sh

log "Welcome to Gitorious 3.2 installer!"

echo
echo "Following information will be used to generate configuration file and SSL certificate:"
read -e -p "  hostname (FQDN): " -i $(hostname) GITORIOUS_HOST
echo

install_ansible

log "Starting installation procedure..."

ansible-playbook -c local -i hosts install.yml --extra-vars "gitorious_host=$GITORIOUS_HOST"
rm /tmp/.gitorious*

anonymous_pingback

echo
log "Your installation of Gitorious Community Edition is complete."
log "Open https://$GITORIOUS_HOST/ in your browser to start."
log "Log in as admin with \"admin\" / \"g1torious\" as credentials."
echo
log "This installer is created and supported by Gitorious AS."
log "For professional support contact us at sales@gitorious.org"
log "http://gitorious.com"
