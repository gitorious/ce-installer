class gitorious::database {
  $packages = ["mysql","mysql-devel","mysql-server"]

  Exec { path => ["/opt/rubies/ruby-1.9.3-p448/bin/","/usr/local/bin","/usr/bin","/bin"] }

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
    require => File["/usr/local/bin/gitorious"],
  }

  $bundler_version = "1.3.5"

  exec { "install_bundler":
    command => "gem install --no-ri --no-rdoc -v '$bundler_version' bundler",
    creates => "${gem_path}/bundler-$bundler_version",
    require => [Package["mysql-devel"], Exec["clone_gitorious_source"]],
  }

  exec {"bundle_install":
    command => "/bin/sh -c '/bin/env BUNDLE_GEMFILE=${gitorious::app_root}/Gemfile bundle install --deployment --without development test && touch /tmp/bundles_installed'",
    require => File["bundler_config_file"],
    creates => "/tmp/bundles_installed",
  }

  file {"bundler_config_home":
    path => "${gitorious::app_root}/.bundle",
    require => Exec["install_bundler"],
    ensure => directory,
    owner => "git",
    group => "git",
    mode => "0755",
  }

  file {"bundler_config_file":
    path => "${gitorious::app_root}/.bundle/config",
    require => File["bundler_config_home"],
    ensure => present,
    owner => "git",
    group => "git",
    mode => "0644",
    source => "puppet:///modules/gitorious/bundler_config",
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
