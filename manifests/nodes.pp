# -*- coding: utf-8 -*-
node default inherits gitorious-ce {

}

node gitorious-ce {
  case $::operatingsystem {
    default: { notify{'Not supported on your OS': } }
    /CentoS|Redhat/: {
      $cron_name = $::operatingsystemrelease? {
        /^5.*/ => 'vixie-cron',
        /^6.*/ => 'cronie',
      }
      package { $cron_name:
        ensure => installed,
      }
    }
  }

  include iptables
  include iptables::default_firewall
  include gitorious
  include gitorious::git
  include gitorious::dependencies
  include gitorious::sphinx
  include gitorious::core
  include gitorious::database
  include gitorious::logrotate
  include gitorious::unicorn
  include gitorious::nginx
  include gitorious::utils
  include resque

  case $::operatingsystem {
    default: { notify{'Not supported on your OS': } }
    CentOS: { include centos }
    Redhat: { include redhat }
  }

  case $architecture {
    i386: { $gem_path = "/usr/lib/ruby/gems/1.8/gems" }
    default: { $gem_path = "/usr/lib64/ruby/gems/1.8/gems" }
  }

  group { "puppet":
    ensure => "present",
  }

  $server_name = $fqdn

  gitorious::nginx::vhost_with_self_signed_certs { $server_name: }

  gitorious::config {$server_name:
    server_name => $server_name,
    require_ssl => true,
    public_mode => "false",
  }

  gitorious::version { "v2.4.12":

  }

  include gitorious::native_git_daemons
}
