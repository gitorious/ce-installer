class resque {
  package { "redis":
    ensure => installed,
  }

  service { "redis":
    enable => true,
    ensure => running,
    require => Package["redis"],
  }

  file {"/etc/init/resque-worker":
    ensure => present,
    mode => 644,
    content => template("rescue-worker.conf.erb"),
  }
}
