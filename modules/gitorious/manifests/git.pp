class gitorious::git {

  user {"git":
    ensure => present,
    home => $gitorious::install_root,
  }

  group {"git":
    ensure => present,
    require => User["git"],
  }

  file {"gitorious_root":
    path => $gitorious::install_root,
    ensure => directory,
    owner => "git",
    group => "git",
    mode => 644,
    require => Group["git"],
  }

  $_gitorious_home = $gitorious::app_root
  file { "gitorious_console":
    path => "/usr/local/bin/gitorious_console",
    ensure => present,
    mode => 700,
    owner => "git",
    group => "git",
    content => template("gitorious/scripts/gitorious_console.erb"),
    require => User["git"],
  }

  file {"repository_root":
    ensure => directory,
    path => $gitorious::repository_root,
    owner => "git",
    group => "git",
    mode => 750,
    require => File["gitorious_root"],
  }

  file {"ssh_root":
    path => "${gitorious::install_root}/.ssh",
    owner => "git",
    group => "git",
    ensure => directory,
    mode => 700,
    require => Group["git"],
  }

  file {"authorized_keys":
    path => "${gitorious::install_root}/.ssh/authorized_keys",
    ensure => present,
    owner => "git",
    group => "git",
    mode => 600,
    require => File["ssh_root"],
  }

  file {"tarball_cache":
    path => "${gitorious::install_root}/tarballs-cache",
    ensure => directory,
    mode => 0755,
    owner => "git",
    group => "git",
  }

  file {"tarball_work":
    path => "${gitorious::install_root}/tarballs-work",
    ensure => directory,
    mode => 0755,
    owner => "git",
    group => "git",
  }
  package {"git":
    ensure => installed,
  }
}
