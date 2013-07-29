class gitorious::dependencies {

  # Default path
  Exec { path => ["/opt/ruby-enterprise/bin","/usr/local/bin","/usr/bin","/bin", "/usr/sbin"] }

  case $operatingsystem {
    CentOS: { $package_list = ["monit", "memcached", "ImageMagick","gcc-c++","zlib-devel","make","wget","libxml2","libxml2-devel","libxslt","libxslt-devel","gcc", "ruby-devel", "openssl", "postgresql-devel.x86_64", "postfix", "libicu-devel"]}
  }

  package { $package_list: ensure => installed }

  case $operatingsystemrelease {
    5.6: {
      package { "curl-devel": ensure => installed }
    }
    default: {
      package { "libcurl-devel": ensure => installed }
    }
  }

  service { "postfix":
    ensure => running,
    enable => true,
    require => Package["postfix"],
  }

  package { "exim":
    ensure => absent,
  }

  service { "memcached":
    enable => true,
    ensure => running,
    require => Package["memcached"],
  }

  service {"monit":
    enable => true,
    ensure => running,
    require => [
                Package["monit"],
                File["/etc/gitorious.conf"],
                ],
  }

  file {"/etc/monit.conf":
    ensure => present,
    owner => "root",
    group => "root",
    mode => "0600",
    source => "puppet:///modules/gitorious/config/monit.conf",
    require => Package["monit"],
  }

}
