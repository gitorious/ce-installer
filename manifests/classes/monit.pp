class monit {

  define config($t_app_root="", $t_control_scripts_dir="", $fqdn=false, $pids_dir="", $pidfile="", $repo_root="") {
    file{"/etc/monit.d/${name}.monit":
      ensure => present,
      owner => "root",
      group => "root",
      mode => "0644",
      content => template("gitorious/monit.d/${name}.monit.erb"),
      require => Package["monit"],
      notify => Service["monit"],
    }
  }
}
