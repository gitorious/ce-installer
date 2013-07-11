# -*- coding: utf-8 -*-
node default inherits gitorious-ce {

}

node gitorious-ce {
  package { "cronie":
    ensure => installed,
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

  case $operatingsystem {
    CentOS: { include centos }
  }

  $gem_path = "/opt/rubies/ruby-1.9.3-p448/lib/ruby/gems/1.9.1/gems/"

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

  gitorious::version { "v3-rc1":

  }

  gitorious::gitorious_chruby_wrapper_script {}

  include gitorious::native_git_daemons
}
