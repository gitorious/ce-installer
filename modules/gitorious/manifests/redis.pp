class gitorious::redis {
  package { "redis":
    ensure => installed,
  }

  monit::config{ "redis": }

  service { "redis":
    enable => true,
    ensure => running,
    require => Package["redis"],
  }
}
