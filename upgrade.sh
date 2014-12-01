#!/bin/bash

set -e

source functions/all.sh

log "Welcome to Gitorious upgrader!"
log "This script will update Gitorious installation on this machine to $gitorious_version."
echo
log "It will first shutdown all Gitorious processes and then apply the upgrade steps."
log "Hit <Enter> to continue."
read

# TODO: shutdown

install_gitorious upgrade

echo
log "Upgrade of your Gitorious installation is complete."
log "Open https://$gitorious_host/ in your browser to start."
echo
footnote
