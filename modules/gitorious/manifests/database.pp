class gitorious::database {
  $packages = ["mysql","mysql-devel","mysql-server"]

  Exec { path => ["/opt/rubies/ruby-${ruby_version}/bin/","/usr/local/bin","/usr/bin","/bin"] }

  package { $packages: ensure => installed }

  service {"mysqld":
    ensure => running,
    enable => true,
    require => Package["mysql-server"],
  }

  mysql::create_database { "gitorious_production":
    username => "gitorious",
    password => "DB_PASSWORD",
  }

  file {"db_seed":
    path => "${gitorious::app_root}/db/seeds.rb",
    ensure => present,
    source => "puppet:///modules/gitorious/config/seeds.rb",
    owner => "git",
    group => "git",
    require => File["/usr/bin/gitorious"],
  }

  $bundler_version = "1.3.5"

  exec { "install_bundler":
    command => "gem install --no-ri --no-rdoc -v '$bundler_version' bundler",
    creates => "${gem_path}/bundler-$bundler_version",
    require => [Package["mysql-devel"], Exec["clone_gitorious_source"]],
  }

  exec {"bundle_install":
    command => "bundle install --deployment --without development test && touch /tmp/bundles_installed",
    timeout => 900,
    cwd => "${gitorious::app_root}",
    creates => "/tmp/bundles_installed"
  }

  exec {"populate_database":
    command => "${gitorious::app_root}/bin/rake db:setup && touch ${gitorious::app_root}/tmp/database_populated",
    creates => "${gitorious::app_root}/tmp/database_populated",
    require => [
                File["db_seed"],
                Mysql::Create_database["gitorious_production"],
                Exec["bundle_install"],
                ],
  }

}
