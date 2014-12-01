install_gitorious() {
  prompt_for_hostname
  echo

  install_ansible

  log "Starting $1 procedure..."
  ansible-playbook -c local -i hosts install.yml --extra-vars "gitorious_host=$gitorious_host gitorious_version=$gitorious_version"
  rm /tmp/.gitorious*
}
