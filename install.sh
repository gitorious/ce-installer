#!/bin/bash

set -e

source functions/functions.sh

log "Starting Gitorious installation..."

require_root
prompt_for_settings
install_docker
setup_git_user
generate_config_file
generate_mysql_env_file
create_containers
install_gitoriousctl
setup_admin_account
anonymous_pingback

log ""
log "Your installation of Gitorious Community Edition is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
