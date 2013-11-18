#!/bin/bash -l

upgrade-gitorious-from-v2-to-v3 () {
  stop-gitorious
  uninstall-ruby-18
  install-ruby-19
  update-executables-to-use-chruby
  checkout-gitorious-v3
  install-dependencies
  migrate-database
  start-gitorious
}

stop-gitorious () {
  /etc/init.d/gitorious-unicorn stop
  stop resque-worker
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
  ./render_config.rb /vagrant/ce-installer/modules/gitorious/templates/etc/init.d/gitorious-unicorn.erb > /etc/init.d/gitorious-unicorn

  ./render_config.rb /vagrant/ce-installer/modules/resque/templates/etc/init/resque-worker.conf.erb > /etc/init/resque-worker.conf

  cp modules/gitorious/templates/usr/bin/gitorious.erb /usr/bin/gitorious
  chmod +x /usr/bin/gitorious
  rm -f /usr/local/bin/gitorious
}

checkout-gitorious-v3 () {
  cd /var/www/gitorious/app

  git fetch --all
  git checkout master -f
  git submodule init
  git submodule update --recursive
}

install-dependencies () {
  gem install bundler
  yum -y install libicu-devel patch
  bundle install --deployment --without development test postgres
}

migrate-database () {
  sed -i s/mysql\\b/mysql2/ config/database.yml
  RAILS_ENV=production bundle exec rake db:migrate
}

start-gitorious () {
  /etc/init.d/gitorious-unicorn restart
  start resque-worker
}

upgrade-gitorious-from-v2-to-v3
