#!/bin/bash

set -e

source functions/all.sh

log "Welcome to Gitorious installer!"
log "This script will install Gitorious $gitorious_version on this machine."
echo

install_gitorious installation

anonymous_pingback

echo
log "Your installation of Gitorious Community Edition is complete."
log "Open https://$gitorious_host/ in your browser to start."
log "Log in as admin with \"admin\" / \"g1torious\" as credentials."
echo
footnote
