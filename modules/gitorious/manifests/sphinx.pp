class gitorious::sphinx {

  Exec { path => ["/opt/rubies/ruby-1.9.3-p448/bin/", "/usr/local/bin","/usr/bin","/bin", "/usr/sbin"] }

  $app_root = $gitorious::app_root

  # Installed after database has been populated
  package { "sphinx":
    ensure => installed,
  }

  exec { "bootstrap_thinking_sphinx":
    command => "${gitorious::app_root}/bin/rake ts:configure",
    require => [Package["sphinx"], Exec["bundle_install"], Exec["populate_database"]],
    creates => "${gitorious::app_root}/config/production.sphinx.conf",
  }

  monit::config { "thinking-sphinx":
    t_app_root => $gitorious::app_root,
  }

  cron { "reindex_sphinx":
    command => "${gitorious::app_root}/bin/rake ts:rebuild >/dev/null 2>/dev/null",
    minute => "00",
    require => Exec["bootstrap_thinking_sphinx"],
  }


}
