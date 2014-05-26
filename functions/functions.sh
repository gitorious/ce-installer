source functions/utils.sh
source functions/docker.sh
source functions/setup_git.sh
source functions/containers.sh

install_gitoriousctl() {
  log "Installing gitoriousctl control script..."

  cp resources/usr/bin/gitoriousctl /usr/bin/gitoriousctl
}

generate_env() {
  mkdir -p /var/lib/gitorious

  read -e -p "Enter hostname: " -i `hostname -f` GITORIOUS_HOST
  read -e -p "Enter admin's email: " GITORIOUS_ADMIN_EMAIL

  cat <<EOS >/var/lib/gitorious/env
GITORIOUS_HOST=$GITORIOUS_HOST
GITORIOUS_ADMIN_EMAIL=$GITORIOUS_ADMIN_EMAIL
MYSQL_ROOT_PASSWORD=`random_password`
MYSQL_DATABASE=gitorious
MYSQL_USER=gitorious
MYSQL_PASSWORD=`random_password`
EOS

  chown git:git /var/lib/gitorious/env
}

random_password() {
  openssl rand -base64 32
}

setup_admin_account() {
  log "Creating admin account"
  gitoriousctl run bin/create-user
}
