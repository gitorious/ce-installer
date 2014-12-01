log() {
  echo -e "\e[1;32m+\e[31m-\e[0m \e[1m$@\e[0m"
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

prompt_for_hostname() {
  echo "Following information will be used to generate configuration file and SSL certificate:"
  read -e -p "  hostname (FQDN): " -i $(hostname) gitorious_host
}

footnote() {
  log "This script is created and supported by Gitorious AS."
  log "For professional support contact us at sales@gitorious.org"
  log "http://gitorious.com"
}
