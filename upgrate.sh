echo "Uninstalling Ruby 1.8.7"
yum -y remove ruby
yum -y install libicu-devel

echo "Installing Ruby 1.9.3"
./install-ruby.sh
echo "Make sure we are using the proper Ruby version..."
source /etc/profile.d/chruby.sh

cd /var/www/gitorious/app

git fetch --all
git checkout master -f
git submodule init
git submodule update --recursive

gem install bundler

bundle install --deployment --without development test postgres

RAILS_ENV=production bundle exec rake db:migrate
