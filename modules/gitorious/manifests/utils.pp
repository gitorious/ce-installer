class gitorious::utils {
  $app_root = $gitorious::app_root
  file { "/usr/bin/gitorious_status":
    ensure => present,
    owner => root,
    group => root,
    mode => "0755",
    content => template("gitorious/usr/bin/gitorious_status.erb"),
  }
}
