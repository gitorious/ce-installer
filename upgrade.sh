#!/bin/bash

set -e

source functions.sh

log "Starting Gitorious upgrade..."

require_root
pull_latest_images
stop_gitorious_services
uninstall_gitorious_services
remove_containers
start_containers
install_gitorious_services
start_gitorious_services

log ""
log "Upgrade of your Gitorious Community Edition installation is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
