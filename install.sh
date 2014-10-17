#!/bin/bash

set -e

source functions/all.sh

log "Starting Gitorious 3.2 installation..."

require_root
install_ansible
# prompt_for_settings
# generate_config_file
# generate_mysql_env_file
ansible-playbook -c local -i hosts install.yml
# anonymous_pingback

echo
log "Your installation of Gitorious Community Edition is complete."
log "This installer is created and supported by Gitorious AS."
log "For professional, long-term support, please consider Gitorious Enterprise Edition."
log "http://gitorious.com"
