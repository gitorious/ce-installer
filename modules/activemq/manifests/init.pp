class activemq {
  $activemq_home = "/usr/local/activemq"

  package{"java-1.6.0-openjdk":
    ensure => installed;
  }
  $activemq_version = "5.4.3"
  user {"activemq":
    ensure => present,
    home => $activemq_home,
    managehome => false,
    shell => "/bin/sh",
  }

  group {"activemq":
    ensure => present,
    require => User["activemq"],
  }

  Exec{path => ["/usr/local/bin","/usr/bin","/bin"]}

  $puppet_cache = "/usr/local/src/gitorious"

  file {$puppet_cache:
    ensure => directory,
    owner => "root",
    group => "root",
  }

  tarball::extract_and_symlink_remote_tarball{"apache-activemq-${activemq_version}":
    cwd => $puppet_cache,
    url => "http://mirrors.powertech.no/www.apache.org/dist/activemq/apache-activemq/${activemq_version}/apache-activemq-${activemq_version}-bin.tar.gz",
    target => $activemq_home,
    owner => "activemq",
    group => "activemq",
  }

  file {"/etc/activemq.conf":
    ensure => file,
    mode => 644,
    content => template("activemq/etc/activemq.conf.erb"),
    require => Tarball::Extract_and_symlink_remote_tarball["apache-activemq-${activemq_version}"],
  }

  file {"/etc/init.d/activemq":
    ensure => file,
    mode => 755,
    owner => "root",
    group => "root",
    content => template("activemq/etc/init.d/activemq.erb"),
    require => File["/etc/activemq.conf"],
  }

  service{"activemq":
    enable => true,
    ensure => running,
    require => File["/etc/init.d/activemq"],
  }

  file { "activemq.xml":
    path => "$activemq_home/conf/activemq.xml",
    ensure => present,
    mode => 644,
    owner => "activemq",
    group => "activemq",
    content => template("activemq/activemq.xml.erb"),
    require => File["/etc/init.d/activemq"],
    notify => Service["activemq"],
  }

}
