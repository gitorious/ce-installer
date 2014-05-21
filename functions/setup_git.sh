git_user_exists() {
  id git &>/dev/null
}

create_git_user() {
  useradd -m -u 5000 -U -d /home/git git
}

generate_key_pair() {
  su git -c "ssh-keygen -f /home/git/.ssh/id_rsa -P ''"
  mkdir -p /var/lib/gitorious/.ssh
  chown git:git /var/lib/gitorious/.ssh
  su git -c "cp /home/git/.ssh/id_rsa.pub /var/lib/gitorious/.ssh/git_id_rsa.pub"
}

generate_bin_gitorious() {
  cp resources/usr/bin/gitorious /usr/bin/gitorious
}

setup_authorized_keys() {
  su git -c "ln -fs /var/lib/gitorious/.ssh/authorized_keys /home/git/.ssh/authorized_keys"
}

setup_git_user() {
  if git_user_exists; then
    log "Git user already created"
  else
    log "Setting up a git user"
    create_git_user
    generate_key_pair
    generate_bin_gitorious
    setup_authorized_keys
  fi
}
