#!/bin/bash -l

source config.sh

GITORIOUS_VERSION=${GITORIOUS_VERSION:-v3.0.1}

upgrade-gitorious-from-v2-to-v3 () {
  stop-gitorious
  uninstall-ruby-18
  install-ruby-19
  update-executables-to-use-chruby
  update-nginx-configuration
  checkout-gitorious-v3
  install-dependencies
  compile-assets
  migrate-database
  fix-invalid-data
  update-searchd
  update-owner
  start-gitorious
  migrate-configuration
  print-configuration-warnings
}

stop-gitorious () {
  if [ -f /etc/init.d/gitorious-unicorn ];
  then
    /etc/init.d/gitorious-unicorn stop
  else
    monit stop unicorn
  fi
  stop resque-worker
  service nginx stop
}

uninstall-ruby-18 () {
  echo "Uninstalling Ruby 1.8.7"
  yum -y remove ruby
}

install-ruby-19 () {
  echo "Installing Ruby 1.9.3"
  ./install-ruby.sh
  echo "Make sure we are using the proper Ruby version..."

  source /etc/profile.d/chruby.sh
  chruby 1.9.3
}

update-executables-to-use-chruby () {
  ./render_config.rb modules/gitorious/templates/monit.d/thinking-sphinx.monit.erb > /etc/monit.d/thinking-sphinx.monit

  ./render_config.rb modules/gitorious/templates/monit.d/unicorn.monit.erb > /etc/monit.d/unicorn.monit
  monit reload

  ./render_config.rb modules/gitorious/templates/unicorn.rb.erb > /var/www/gitorious/app/config/unicorn.rb
  ./render_config.rb modules/gitorious/templates/etc/init.d/gitorious-unicorn.erb > /etc/init.d/gitorious-unicorn
  chmod +x /etc/init.d/gitorious-unicorn

  ./render_config.rb modules/gitorious/templates/usr/bin/gitorious_status.erb > /usr/bin/gitorious_status
  chmod +x /usr/bin/gitorious_status

  ./render_config.rb modules/resque/templates/etc/init/resque-worker.conf.erb > /etc/init/resque-worker.conf

  cp modules/gitorious/templates/usr/bin/gitorious.erb /usr/bin/gitorious
  chmod +x /usr/bin/gitorious
  rm -f /usr/local/bin/gitorious
}

update-nginx-configuration() {
  sed -i s/current\\/// /etc/nginx/conf.d/gitorious.conf
}

checkout-gitorious-v3 () {
  cd /var/www/gitorious/app

  git fetch --all
  git checkout $GITORIOUS_VERSION -f
  git submodule init
  git submodule update --recursive
}

install-dependencies () {
  gem install bundler
  yum -y install libicu-devel patch sphinx
  bundle install --deployment --without development test postgres
}

compile-assets () {
  RAILS_ENV=production bundle exec rake assets:precompile
}

migrate-database () {
  sed -i s/mysql\\b/mysql2/ config/database.yml
  RAILS_ENV=production bundle exec rake db:migrate
}

update-searchd () {
  cd /var/www/gitorious/app
  RAILS_ENV=production bundle exec rake ts:configure
  RAILS_ENV=production bundle exec rake ts:rebuild
}

update-owner () {
  chown git:git -R /var/www/gitorious/app
}

migrate-configuration () {
  echo
  echo "If you are upgrading from 2.x you need to migrate gitorious.yml."
  echo "The following snippet run on 3.x config will result in lost settings!"
  echo "To upgrade the config run following commands as git user and then inspect the result:"
  echo
  echo "cd /var/www/gitorious/app"
  echo "bin/upgrade-gitorious3-config config/gitorious.yml config/gitorious.yml"
  echo
}

fix-invalid-data () {
 cd /var/www/gitorious/app && RAILS_ENV=production bundle exec rake fix_dangling_comments fix_dangling_memberships fix_missing_wiki_repos fix_dangling_committerships fix_dangling_projects fix_system_comments fix_dangling_events fix_dangling_repositories fix_dangling_favorites fix_missing_repos 
}

start-gitorious () {
  /etc/init.d/gitorious-unicorn restart
  start resque-worker
  service nginx start
}

print-configuration-warnings () {
 echo
 echo "Please fix the following warnings in your config/gitorious.yml:"
 echo
 cd /var/www/gitorious/app && RAILS_ENV=production bundle exec rails r ''
}

upgrade-gitorious-from-v2-to-v3
