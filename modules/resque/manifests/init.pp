class resque {
  package { "redis":
    ensure => installed,
  }

  service { "redis":
    enable => true,
    ensure => running,
    require => Package["redis"],
  }
  $app_root = $gitorious::app_root

  file {"/etc/init/resque-worker.conf":
    ensure => present,
    mode => 644,
    content => template("resque/resque-worker.conf.erb"),
  }
}
