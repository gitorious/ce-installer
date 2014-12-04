gitorious_version=${VERSION:-v3.2.0}

install_gitorious() {
  echo "Following information will be used to generate configuration file and SSL certificate:"
  read -e -p "  hostname (FQDN): " -i $(hostname -f 2>/dev/null || hostname) gitorious_host
  echo

  install_ansible

  log "Starting $1 procedure..."
  ansible-playbook -c local -i hosts install.yml --extra-vars "gitorious_host=$gitorious_host gitorious_version=$gitorious_version"
}
