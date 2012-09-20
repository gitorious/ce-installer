class iptables::default_firewall {
  file { "/etc/sysconfig/iptables":
    ensure => present,
    source => "puppet:///modules/iptables/default_firewall",
    owner => "root",
    group => "root",
    mode => "0600",
    notify => Service["iptables"],
  }

  service { "iptables":
    ensure => running,
    enable => true,
  }
}
