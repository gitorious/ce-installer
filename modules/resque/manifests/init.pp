class resque {
  $resque_gitorious_root = $gitorious::app_root

  package { "redis":
    ensure => installed,
  }

  service { "redis":
    ensure => running,
    enable => true,
    require => Package["redis"],
  }

  file { "/etc/init/resque-worker.conf":
    ensure => present,
    owner => root,
    group => root,
    content => template("resque/etc/init/resque-worker.conf.erb"),
    require => Service["redis"],
  }
}
