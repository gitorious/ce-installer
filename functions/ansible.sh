ansible_installed() {
  hash ansible-playbook 2>/dev/null
}

install_ansible() {
  if ansible_installed; then
    return
  else
    log "Installing ansible..."

    if ubuntu_release; then
      sudo apt-get update -y >/dev/null
      sudo apt-get install -y python-pip python-dev libmysqlclient-dev >/dev/null
      sudo pip install ansible MySQL-python >/dev/null
    fi

    if redhat_release; then
      sudo yum install -y epel-release >/dev/null
      sudo yum install -y ansible MySQL-python >/dev/null
    fi
  fi
}
