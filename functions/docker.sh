install_docker_redhat() {
  rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum -y install docker-io
  service docker start
  chkconfig docker on
}

install_docker_ubuntu() {
  apt-get install -y docker.io
  ln -sf /usr/bin/docker.io /usr/bin/docker
}

docker_installed() {
  hash docker 2>/dev/null
}

ubuntu_release() {
  grep "Ubuntu" /proc/version >/dev/null
}

redhat_release() {
  grep "Red Hat" /proc/version >/dev/null
}

install_docker() {
  if docker_installed; then
    log "Docker already installed"
    return
  else
    log "Installing Docker"

    if ubuntu_release; then
      install_docker_ubuntu
    fi

    if redhat_release; then
      install_docker_redhat
    fi
  fi
}

require_docker() {
  if ! docker_installed; then
    log "It seems you're trying to upgrade pre-docker Gitorious instance."
    log "Use migrate.sh to upgrade your installation."
    exit 1
  fi
}
