class gitorious::sphinx {

  Exec { path => ["/usr/local/bin","/usr/bin","/bin", "/usr/sbin"] }

  $app_root = $gitorious::app_root

  # Installed after database has been populated
  package { "sphinx":
    ensure => installed,
    require => File["/etc/gitorious.conf"],
  }

  # Added after package is installed
  exec { "bootstrap_ultrasphinx":
    command => "/bin/sh -c 'cd ${gitorious::app_root} && /bin/env RAILS_ENV=production BUNDLE_GEMFILE=${gitorious::app_root}/Gemfile bundle exec rake ultrasphinx:bootstrap && chown -R git:git db/sphinx && chown -R git:git config/ultrasphinx/production.conf'",
#    command => "/bin/env RAILS_ENV=production bundle --gemfile=${gitorious::app_root}/Gemfile exec gem list",
    require => Package["sphinx"],
    creates => "${gitorious::app_root}/config/ultrasphinx/production.conf",    
  }

  file { "/etc/init.d/git-ultrasphinx":
    ensure => present,
    owner => "root",
    group => "root",
    mode => "0700",
    content => template("gitorious/git-ultrasphinx.erb"),
    require => Exec["bootstrap_ultrasphinx"],
  }

  service { "git-ultrasphinx":
    enable => true,
    ensure => running,
    require => File["/etc/init.d/git-ultrasphinx"],
  }

  cron { "reindex_sphinx":
    command => "cd ${gitorious::app_root} && RAILS_ENV=production /usr/bin/bundle exec rake ultrasphinx:index >> ${gitorious::app_root}/log/sphinx.log",
    user => "git",
    minute => "00",
    require => Exec["bootstrap_ultrasphinx"],
  }

  
}
