class gitorious::nginx {
  package { "nginx":
    ensure => installed,
  }

  file { "/var/www":
    ensure => directory,
    owner => root,
    group => git,
    mode => 0750,
  }

  service { "web-server":
    name => "nginx",
    enable => true,
    ensure => running,
    require => Package["nginx"],
  }


  file { "/etc/nginx/conf.d/ssl.conf":
    ensure => absent,
  }

  file { "/etc/nginx/conf.d/virtual.conf":
    ensure => absent,
  }

  file { "/etc/nginx/conf.d/default.conf":
    ensure => absent,
  }

  file { "/etc/nginx/nginx.conf":
    ensure => present,
    owner => root,
    group => git,
    content => template("gitorious/etc/nginx/nginx.conf.erb"),
    require => File["/etc/gitorious.conf"],
  }


  define vhost($certificate_file="/etc/pki/tls/certs/localhost.crt", $certificate_key_file="/etc/pki/tls/private/localhost.key", $ca_chain=false) {
    $nginx_gitorious_root = $gitorious::app_root
    $nginx_tarballs_root = $gitorious::tarballs_cache
    $nginx_repo_root = $gitorious::repository_root
    $server_name = $name
    file { "/etc/nginx/conf.d/gitorious.conf":
      ensure => present,
      owner => root,
      group => root,
      content => template("gitorious/etc/nginx/conf.d/gitorious.conf.erb"),
      require => Package["nginx"],
      notify => Service["nginx"],
    }
  }

  define vhost_with_self_signed_certs($subject="/C=NO/ST=Oslo/L=Oslo/CN=${name}") {
    $cert = "/etc/pki/tls/certs/gitorious.crt"
    $key = "/etc/pki/tls/private/gitorious.crt"

    gitorious::nginx::vhost { $name:
      certificate_file => $cert,
      certificate_key_file => $key,
      ca_chain => $ca_chain,
      require => Exec["create_server_certs"],
    }

    exec { "create_server_certs":
      creates => $cert,
      command => "/usr/bin/openssl req -x509 -nodes -days 3650 -subj '${subject}' -newkey rsa:1024 -keyout ${key} -out ${cert}",
      require => Package["openssl"],
    }
  }

}
