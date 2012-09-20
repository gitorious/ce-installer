class gitorious::dependencies {

  # Default path
  Exec { path => ["/opt/ruby-enterprise/bin","/usr/local/bin","/usr/bin","/bin", "/usr/sbin"] }

  case $operatingsystem {
    CentOS: { $package_list = ["httpd","httpd-devel","apr-devel","apr-util-devel","mod_ssl", "monit", "memcached", "ImageMagick","gcc-c++","zlib-devel","make","wget","libxml2","libxml2-devel","libxslt","libxslt-devel","gcc","crontabs"]}
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
  
  service { httpd:
    name => $operatingsystem ? {
      Centos => "httpd",
    },
    enable => true,
    ensure => running,
    subscribe => File["/etc/httpd/conf.d/passenger.conf"],
    require => Exec["install_xsendfile"],
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


  monit::config { "gitorious-poller":
    t_app_root => $gitorious::app_root,
    t_control_scripts_dir => $gitorious::control_scripts_dir,
  }


  exec {"install_passenger_module":
    command => "passenger-install-apache2-module -a && touch /opt/passenger_installed",
    creates => "/opt/passenger_installed",
    require => Exec["install_our_passenger"],
  }

  exec {"install_our_passenger":
    command => "gem install --no-ri --no-rdoc -v '${gitorious::passenger_version}' passenger",
    creates => "${gem_path}/passenger-${gitorious::passenger_version}",
    require => Package["mod_ssl","httpd-devel","apr-devel","apr-util-devel"],
  }

  file {"/etc/httpd/conf.d/passenger.conf":
    require => Exec["install_passenger_module"],
    owner => "root",
    group => "root",
    content => template("gitorious/passenger.conf.erb"),
  }

  file {"/etc/httpd/conf.d/ssl.conf":
    ensure => absent,
  }

  exec {"install_xsendfile":
    command => "/bin/sh -c 'cd /tmp && wget --no-check-certificate https://tn123.org/mod_xsendfile/mod_xsendfile.c && apxs -cia mod_xsendfile.c'",
    creates => "/etc/httpd/modules/mod_xsendfile.so",
    require => Package["httpd-devel"],
  }

}
