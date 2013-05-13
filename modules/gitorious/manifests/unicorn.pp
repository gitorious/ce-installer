class gitorious::unicorn {
  $app_root = "${gitorious::app_root}"
  file { "unicorn.rb":
    path => "${gitorious::app_root}/config/unicorn.rb",
    owner => git,
    group => git,
    require => File["/etc/gitorious.conf"],
    ensure => present,
    content => template("gitorious/unicorn.rb.erb"),
  }

  file { "/etc/init.d/gitorious-unicorn":
    owner => root,
    group => root,
    mode => 0755,
    require => File["unicorn.rb"],
    content => template("gitorious/etc/init.d/gitorious-unicorn.erb")
  }

  monit::config{ "unicorn":
    pids_dir => "/var/www/gitorious/app/tmp/pids",
    t_app_root => "/var/www/gitorious/app",
  }
  service { "gitorious-unicorn":
    require => File["/etc/init.d/gitorious-unicorn"],
    enable => true,
    ensure => running,
  }

  file { "/usr/bin/restart_gitorious":
    ensure => present,
    owner => root,
    group => root,
    mode => "0744",
    content => template("gitorious/usr/bin/restart_gitorious.erb"),
  }
}
