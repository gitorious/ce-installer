class gitorious::core {

  Exec { path => ["/opt/ruby-enterprise/bin","/usr/local/bin","/usr/bin","/bin"] }

  exec {"clone_gitorious_source":
    command => "git clone -b v2.3.0 git://gitorious.org/gitorious/mainline.git ${gitorious::app_root}",
    creates => "${gitorious::app_root}",
    require => File["gitorious_root"],
  }

  exec {"init_gitorious_submodules":
    command => "git submodule update --init",
    creates => "${gitorious::app_root}/public/javascripts/lib/capillary/package.json",
    cwd => "${gitorious::app_root}",
    require => File["gitorious_root"],
  }

  file {"/usr/local/bin/gitorious":
    ensure => link,
    target => "${gitorious::app_root}/script/gitorious",
    require => Exec["clone_gitorious_source"],
  }

  file {"pids":
    path => "${gitorious::app_root}/tmp/pids",
    ensure => directory,
    mode => 755,
    owner => "git",
    group => "git",
    require => Exec["clone_gitorious_source"],
  }

  # The presence of this file indicates that the Rails app is installed
  # and ready to be used (migrated, gems installed etc)
  # Services etc that need the app to be functional can require this file.
  $gitorious_conf_root = $gitorious::install_root
  file { "/etc/gitorious.conf" :
    ensure => present,
    owner => "root",
    group => "root",
    mode => "0644",
    require => Exec["populate_database"],
    content => template("gitorious/gitorious.conf.erb"),
  }


  file { "restart.txt":
    path => "${gitorious::app_root}/tmp/restart.txt",
    owner => "git",
    group => "git",
    ensure => present,
    require => File["/etc/gitorious.conf"],
  }

  file { "environment.rb":
    path => "${gitorious::app_root}/config/environment.rb",
    owner => "git",
    group => "git",
    ensure => "present",
  }

  exec {"chown_app_root":
    command => "chown -R git:git ${gitorious::app_root} && touch ${gitorious::app_root}/tmp/ownership",
    creates => "${gitorious::app_root}/tmp/ownership",
    require => File["pids"],
  }

  file {"database.yml":
    path => "${gitorious::app_root}/config/database.yml",
    ensure => present,
    owner => "git",
    group => "git",
    require => File["/usr/local/bin/gitorious"],
    source => "puppet:///modules/gitorious/config/database.yml"
  }

  file {"broker.yml":
    path => "${gitorious::app_root}/config/broker.yml",
    ensure => present,
    owner => "git",
    group => "git",
    require => File["/usr/local/bin/gitorious"],
    source => "puppet:///modules/gitorious/config/broker.yml"
  }

  define monit_control_script($script_name) {
    $root = $gitorious::install_root
    $app_root = $gitorious::app_root
    $script_dir = $gitorious::control_scripts_dir

    file {$name:
      path => "$script_dir/$script_name",
      ensure => present,
      owner => "git",
      group => "git",
      mode => "0755",
      require => File["control_scripts"],
      content => template("gitorious/control-scripts/$script_name.erb"),
    }
  }

  monit_control_script {"poller_control.sh":
    script_name => "poller.sh",
  }

  monit_control_script { "git_daemon_control.sh":
    script_name => "git-daemon.sh",
  }
}
