source functions/utils.sh
source functions/install_docker.sh
source functions/setup_git_user.sh
source functions/containers.sh

install_gitoriousctl() {
  log "Installing gitoriousctl control script..."

  cp ./gitoriousctl /usr/bin/gitoriousctl
}
