#!/bin/bash

set -e

source functions/functions.sh

log "Starting Gitorious migration..."

# TODO:
# handle hooks restore
# handle avatars restore
# regenerate indexes after restore (remove from backup:restore?)

require_root
stop_gitorious_services
backup_gitorious
remove_old_git_user
setup_git_user
install_docker
remove_containers
start_containers
install_gitoriousctl
restore_gitorious_backup
cleanup_old_gitorious

log ""
log "Upgrade of your Gitorious Community Edition installation is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
