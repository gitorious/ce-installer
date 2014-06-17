#!/bin/bash

set -e

source functions/functions.sh

log "Starting Gitorious upgrade..."

require_root
require_docker
remove_containers
create_containers
install_gitoriousctl

log ""
log "Upgrade of your Gitorious Community Edition installation is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
