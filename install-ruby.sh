yum install -y wget tar make gcc ntp sudo libyaml-devel

echo "Setting time to avoid makefile warning..."
ntpdate pool.ntp.org

echo "Downloading src tarballs..."
cd /tmp
wget --no-check-certificate -O ruby-install-0.2.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.2.1.tar.gz
tar -xzvf ruby-install-0.2.1.tar.gz
wget --no-check-certificate -O chruby-0.3.6.tar.gz https://github.com/postmodern/chruby/archive/v0.3.6.tar.gz
tar -xzvf chruby-0.3.6.tar.gz

echo "Setting up ruby-install..."
su -c 'cd /tmp/ruby-install-0.2.1/ && make install'

echo "Installing ruby 1.9.3..."
su -c 'ruby-install ruby 1.9.3-p448'

echo "Setting up chruby..."
su -c 'cd /tmp/chruby-0.3.6/ && make install'

echo "Set up 1.9.3 as default ruby version"
echo "source /usr/local/share/chruby/chruby.sh && chruby 1.9.3-p448" >> /etc/profile.d/chruby.sh
chmod a+x /etc/profile.d/chruby.sh

echo "Ruby 1.9.3 installed, ready on next login/new shell."
