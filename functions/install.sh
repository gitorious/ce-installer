gitorious_version=d8199db

install_gitorious() {
  echo "Following information will be used to generate configuration file and SSL certificate:"
  read -e -p "  hostname (FQDN): " -i $(hostname -f || hostname) gitorious_host
  echo

  install_ansible

  log "Starting $1 procedure..."
  ansible-playbook -c local -i hosts install.yml --extra-vars "gitorious_host=$gitorious_host gitorious_version=$gitorious_version"
  rm /tmp/.gitorious*
}
