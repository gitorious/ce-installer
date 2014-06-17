#!/bin/bash

set -e

source functions/all.sh

log "Starting Gitorious migration..."

require_root
install_docker
stop_gitorious_services
backup_gitorious
remove_old_git_user
setup_git_user
generate_mysql_env_file
create_containers
install_gitoriousctl
restore_gitorious_backup
cleanup_old_gitorious

log ""
log "Upgrade of your Gitorious Community Edition installation is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
