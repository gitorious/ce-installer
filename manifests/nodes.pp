# -*- coding: utf-8 -*-
node default inherits gitorious-ce{

}

node gitorious-ce {
  case $operatingsystem {
    CentOS: { include centos }
  }

  case $architecture {
    i386: { $gem_path = "/usr/lib/ruby/gems/1.8/gems" }
    default: { $gem_path = "/usr/lib64/ruby/gems/1.8/gems" }
  }
  
  include activemq
  include gitorious
  include iptables		
  include iptables::default_firewall	
  include gitorious::git
  include gitorious::dependencies
  include gitorious::sphinx
  include gitorious::core
  include gitorious::database
  include gitorious::logrotate
  include gitorious::native_git_daemons

  group { "puppet":
    ensure => "present",
  }
  
  $server_name = $fqdn
  
  gitorious::vhost {"localhost":
    server_name => $server_name,
  }

  gitorious::config {$server_name:
    server_name => $server_name,
    require_ssl => true,
  }

  monit::config { "ultrasphinx":
    
  }
}

