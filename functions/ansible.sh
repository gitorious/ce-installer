ansible_installed() {
  hash ansible-playbook 2>/dev/null
}

install_ansible() {
  if ansible_installed; then
    log "ansible already installed"
    return
  else
    log "Installing ansible"

    if ubuntu_release; then
      # apt-get update -y
      apt-get install -y python-pip
    fi

    if redhat_release; then
      yum install python-pip
    fi

    pip install ansible
  fi
}
