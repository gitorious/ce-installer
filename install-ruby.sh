yum install -y wget tar make gcc ntp sudo libyaml-devel

echo "Setting time to avoid makefile warning..."
ntpdate pool.ntp.org

echo "Downloading src tarballs..."
cd /tmp
if [ ! -f /tmp/ruby-install-0.2.1.tar.gz ]; then
    wget --no-check-certificate -O ruby-install-0.2.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.2.1.tar.gz
fi

if [ ! -d /tmp/ruby-install-0.2.1 ]; then
    tar -xzvf ruby-install-0.2.1.tar.gz
fi

if [ ! -f /tmp/chruby-0.3.6.tar.gz ]; then
    wget --no-check-certificate -O chruby-0.3.6.tar.gz https://github.com/postmodern/chruby/archive/v0.3.6.tar.gz
fi

if [ ! -d /tmp/chruby-0.3.6 ]; then
    tar -xzvf chruby-0.3.6.tar.gz
fi

echo "Setting up ruby-install..."
su -c 'cd /tmp/ruby-install-0.2.1/ && make install'

if [ ! -d /opt/rubies/ruby-1.9.3-p448 ]; then
    echo "Installing ruby 1.9.3..."
    su -c 'ruby-install ruby 1.9.3-p448'
fi

if [ -f /usr/local/bin/ruby-install ]; then
    echo "Setting up chruby..."
    su -c 'cd /tmp/chruby-0.3.6/ && make install'
fi

if [ ! -f /etc/profile.d/chruby.sh ]; then
    echo "Set up 1.9.3 as default ruby version"
    echo "source /usr/local/share/chruby/chruby.sh && chruby 1.9.3-p448" >> /etc/profile.d/chruby.sh
    chmod a+x /etc/profile.d/chruby.sh
end

echo "Ruby 1.9.3 installed, ready on next login/new shell."
