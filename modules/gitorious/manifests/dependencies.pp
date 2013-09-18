class gitorious::dependencies {

  # Default path
  Exec { path => ["/opt/ruby-enterprise/bin","/usr/local/bin","/usr/bin","/bin", "/usr/sbin"] }

  case $::operatingsystem {
    CentOS,RedHat,OracleLinux: {
      $package_list = ["monit", "memcached", "ImageMagick","gcc-c++","zlib-devel","make","wget","libxml2","libxml2-devel","libxslt","libxslt-devel","gcc", "ruby-devel", "openssl"]
    }
  }

  package { $package_list: ensure => installed }

  case $::operatingsystem {
    default: { notify{'Unknown libcurl package name for your OS, please install libcurl and libcurl-devel': } }
    CentOS,RedHat,OracleLinux: {
      case $::operatingsystemrelease {
        default: { notify{'Unknown RHEL Release number, please install libcurl and libcurl-devel': } }
        /^5.*/: {
          package { 'curl-devel': ensure => installed }
        }
        /^6.*/: {
          package { 'libcurl-devel': ensure => installed }
        }
      }
    }
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
