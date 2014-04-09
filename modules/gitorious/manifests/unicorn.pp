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

  file { "/etc/init/gitorious-unicorn.conf":
    ensure => present,
    owner => root,
    group => root,
    require => File["unicorn.rb"],
    content => template("gitorious/etc/init/gitorious-unicorn.conf.erb")
  }

  file { "/usr/bin/restart_gitorious":
    ensure => present,
    owner => root,
    group => root,
    mode => "0744",
    content => template("gitorious/usr/bin/restart_gitorious.erb"),
  }
}
