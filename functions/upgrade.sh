shutdown-old-services() {
  local services='gitorious|unicorn|resque|worker|sphinx|daemon|proxy|activemq|puppet'

  # turn off old upstart services
  initctl list | egrep "$services" | awk '{ print $1 }' | xargs -L1 -I{} sh -c 'stop {}; rm /etc/init/{}.conf' >/dev/null 2>&1 || true

  # turn off old monit services
  monit stop all >/dev/null 2>&1 || true
  /etc/init.d/monit stop >/dev/null 2>&1 || true
  ls -1 /etc/monit.d/ 2>/dev/null | egrep "$services" | xargs -L1 -I{} rm /etc/monit.d/{} >/dev/null 2>&1 || true

  # turn off old SysVinit services
  ls -1 /etc/init.d/ | grep gitorious | xargs -L1 -I{} sh -c '/etc/init.d/{} stop; rm /etc/init.d/{}' >/dev/null 2>&1 || true

  # just to be sure, kill all known processes
  killall unicorn >/dev/null 2>&1 || true
  killall resque >/dev/null 2>&1 || true
  killall sphinx >/dev/null 2>&1 || true
  killall searchd >/dev/null 2>&1 || true
}

backup-configuration() {
  backup_ext="$(date '+%s').backup"
  cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.$backup_ext 2>/dev/null || true
  cp /etc/nginx/conf.d/gitorious.conf /etc/nginx/conf.d/gitorious.conf.$backup_ext 2>/dev/null || true
  cp /var/www/gitorious/app/config/gitorious.yml /var/www/gitorious/app/config/gitorious.yml.$backup_ext 2>/dev/null || true
  cp /var/www/gitorious/app/config/database.yml /var/www/gitorious/app/config/database.yml.$backup_ext 2>/dev/null || true
  cp /var/www/gitorious/app/config/unicorn.rb /var/www/gitorious/app/config/unicorn.rb.$backup_ext 2>/dev/null || true
  cp /var/www/gitorious/app/config/authentication.yml /var/www/gitorious/app/config/authentication.yml.$backup_ext 2>/dev/null || true
}

remove-old-ruby-install() {
  rm -f /usr/local/bin/ruby-install 2>/dev/null || true
  rm -rf /usr/local/share/chruby 2>/dev/null || true
}

update-old-ctl-scripts() {
  if [[ -x /usr/bin/restart_gitorious ]]; then
    update-old-ctl-script /usr/bin/restart_gitorious
  fi

  if [[ -x /usr/bin/gitorious_status ]]; then
    update-old-ctl-script /usr/bin/gitorious_status
  fi
}

update-old-ctl-script() {
  echo "#!/bin/sh" >$1
  echo "echo 'This script is deprecated. Use /usr/bin/gitoriousctl instead.'" >>$1
}
