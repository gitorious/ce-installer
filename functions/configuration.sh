prompt_for_settings() {
  echo "Following information will be used to generate gitorious.yml configuration file:"
  read -e -p "  hostname (FQDN): " -i `hostname -f` GITORIOUS_HOST

  echo "Following information will be used to create Gitorious admin account:"
  read -e -p "  login: " -i admin GITORIOUS_ADMIN_LOGIN
  read -e -p "  password: " -s GITORIOUS_ADMIN_PASSWORD && echo
  read -e -p "  email: " -i "$GITORIOUS_ADMIN_LOGIN@$GITORIOUS_HOST" GITORIOUS_ADMIN_EMAIL
}

generate_config_file() {
  log "Generating main Gitorious config file..."

  mkdir -p /etc/gitorious

  cat resources/etc/gitorious/gitorious.yml |
    sed "s/^#host:.*$/host: $GITORIOUS_HOST/" |
    sed "s/^#support_email:.*$/support_email: $GITORIOUS_ADMIN_EMAIL/" |
    sed "s/^#exception_recipients:.*$/exception_recipients: $GITORIOUS_ADMIN_EMAIL/" >/etc/gitorious/gitorious.yml
}

generate_mysql_env_file() {
  mkdir -p /var/lib/gitorious/env

  cat <<EOS >/var/lib/gitorious/env/mysql
MYSQL_ROOT_PASSWORD=`random_password`
MYSQL_DATABASE=gitorious
MYSQL_USER=gitorious
MYSQL_PASSWORD=`random_password`
EOS
}
