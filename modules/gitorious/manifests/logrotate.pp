class gitorious::logrotate {
  package { "logrotate":
    ensure => present,
    require => File["/etc/gitorious.conf"],
  }

  $logrotate_app_dir = "${gitorious::app_root}"
  file { "/etc/logrotate.d/gitorious" :
    ensure => present,
    owner => "root",
    group => "root",
    mode => "0644",
    require => Package["logrotate"],
    content => template("gitorious/gitorious_logrotate.erb"),    
  }
}
