#!/bin/bash

set -e

source functions/functions.sh

log "Starting Gitorious installation..."

require_root
install_docker
setup_git_user
start_containers
setup_git_known_hosts
install_gitoriousctl
anonymous_pingback

log ""
log "Your installation of Gitorious Community Edition is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
