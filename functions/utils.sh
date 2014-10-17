log() {
  echo -e "\e[1;32m+\e[31m-\e[0m \e[1m$@\e[0m"
}

require_root() {
  if ! [ $(id -u) = 0 ]; then
    log "You should run this script as root/superuser."
    exit 1
  fi
}

ubuntu_release() {
  grep "Ubuntu" /proc/version >/dev/null
}

redhat_release() {
  grep "Red Hat" /proc/version >/dev/null
}

anonymous_pingback() {
  curl -s http://getgitorious.com/installer_completed &>/dev/null || true
}

random_password() {
  openssl rand -base64 32
}
