stop_gitorious_services() {
  log "Stopping old Gitorious services"

  /etc/init.d/gitorious-unicorn stop > /dev/null 2>&1 || true
  monit stop unicorn > /dev/null 2>&1 || true
  stop gitorious-unicorn > /dev/null 2>&1 || true

  monit stop git-daemon > /dev/null 2>&1 || true
  monit stop git-daemons > /dev/null 2>&1 || true
  monit stop git-proxy > /dev/null 2>&1 || true
  stop resque-worker || true
  service nginx stop || true
}

backup_gitorious() {
  log "Creating gitorious backup"
  mkdir -p /var/lib/gitorious/backups
  chown git:git /var/lib/gitorious/backups
  /var/www/gitorious/app/bin/rake backup:snapshot TARBALL_PATH=/var/lib/gitorious/backups/initial_backup.tar RAILS_ENV=production
  cd /tmp
  tar -xf /var/lib/gitorious/backups/initial_backup.tar
  rm tmp-backup-workdir/config/database.yml
  tar -czf /var/lib/gitorious/backups/initial_backup_no_database_config.tar tmp-backup-workdir/
}

remove_old_git_user() {
  log "Removing old git user"
  userdel -r git
}

restore_gitorious_backup() {
  log "Restoring gitorious backup"
  gitoriousctl rake backup:restore TARBALL_PATH=/srv/gitorious/data/backups/initial_backup_no_database_config.tar RAILS_ENV=production
  gitoriousctl restart
}

cleanup_old_gitorious() {
  log "Cleaning up old gitorious installation"
  rm -f /etc/monit.d/puppet /etc/monit.d/puppet.monit \
    /etc/monit.d/git-proxy.monit /etc/monit.d/git-daemon.monit \
    /etc/monit.d/git-daemons.monit /etc/monit.d/thinking-sphinx.monit \
    /etc/monit.d/filesystem_slash.monit /etc/monit.d/gitorious-poller.monit \
    /etc/init.d/activemq /etc/init.d/gitorious-unicorn \
    /etc/init/resque-worker.conf /etc/init/gitorious-unicorn.conf \
    /etc/nginx/conf.d/gitorious.conf /usr/bin/restart_gitorious \
    /usr/bin/gitorious_status

  chkconfig nginx off
  chkconfig searchd off
  chkconfig mysqld off

  mv /var/www/gitorious{,-old}
}
