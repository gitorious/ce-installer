define gitorious::vhost($server_name, $certificate_file="/etc/pki/tls/certs/localhost.crt", $certificate_key_file="/etc/pki/tls/private/localhost.key", $certificate_ca_chain="") {
  $file = "/etc/httpd/conf.d/gitorious.vhost.conf"

  $document_root = "${gitorious::app_root}/public"
  $repository_root = $gitorious::repository_root
  $tarballs_cache = $gitorious::tarballs_cache
  
  file {$file:
    ensure => present,
    owner => "root",
    group => "root",
    notify => Service["httpd"],
    content => template("gitorious/gitorious.vhost.conf.erb"),
    require => Package["httpd"],
  }
}

# A virtual host with real SSL certs. These *must* be inside the puppet repo
define gitorious::vhost_with_real_certs($server_name, $customer_name) {
  $cert = "/etc/pki/tls/certs/${name}.crt"
  $key = "/etc/pki/tls/private/${name}.key"
  $ca_chain = "/etc/pki/tls/${name}_ca_chain.crt"

  gitorious::vhost {$server_name:
    server_name => $server_name,
    certificate_file => $cert,
    certificate_key_file => $key,
    certificate_ca_chain => $ca_chain,
  }
  file { $cert:
    ensure => present,
    owner => root,
    group => root,
    mode => "0600",
    source => "puppet:///modules/gitorious/ssl/clients/$customer_name/${name}.crt",    
  }
  file { $key:
    ensure => present,
    owner => root,
    group => root,
    mode => "0600",
    source => "puppet:///modules/gitorious/ssl/clients/$customer_name/${name}.key",    
  }
  file { $ca_chain:
    ensure => present,
    owner => root,
    group => root,
    mode => "0600",
    source => "puppet:///modules/gitorious/ssl/clients/$customer_name/${name}_ca_chain.crt",    
  }
}

# Specify a tag to run Gitorious from
# Will:
# - fetcch tags from the server
# - merge the specified tag
# - do any required maintenance
define gitorious::version() {
  
  file { $gitorious::deployed_tags_dir:
    ensure => directory,
    owner => git,
    group => git,
    require => File["gitorious_root"],
  }

  exec {"fetch_gitorious_tag":
    command => "sh -c 'cd ${gitorious::app_root} && git fetch --tags && git merge $name && touch ${gitorious::deployed_tags_dir}/$name'",
    creates => "${gitorious::deployed_tags_dir}/$name",
    path => ["/usr/local/bin","/usr/bin","/bin", "/usr/sbin"],
    require => Exec["clone_gitorious_source"],
    notify => Exec["post_version_upgrade"],
  }

  $probe = "${gitorious::deployed_tags_dir}/${name}_requirements"

  exec { "post_version_upgrade":
    command => "sh -c 'export RAILS_ENV=production GIT_SSL_NO_VERIFY=true && cd ${gitorious::app_root} && bundle install && git submodule init && git submodule update && bundle exec rake db:migrate  && rm -f public/stylesheets/gts-*.css public/stylesheets/all.css public/javascripts/all.js && touch tmp/restart.txt && touch $probe'",
    path => ["/usr/local/bin","/usr/bin","/bin", "/usr/sbin"],
    require => File["bundler_config_file"],
    creates => $probe,
  }
  


}

define gitorious::custom_ruby_file($relative_path, $template_file) {
  $file = "${gitorious::app_root}/$relative_path"

  file { $file:
    ensure => present,
    owner => "git",
    group => "git",
    mode => "0755",
    content => template($template_file),
    notify => Service["httpd"],
    require => Exec["clone_gitorious_source"],
  }
}

define gitorious::authentication($host, $port, $base_dn, $dn_templ, $callback_class="") {
  $file = "${gitorious::app_root}/config/authentication.yml"

  file { $file:
    ensure => present,
    owner => "git",
    mode => "0755",
    group => "git",
    content => template("gitorious/authentication.yml.erb"),
    require => Exec["clone_gitorious_source"],
  }
}

define gitorious::config($server_name, $require_ssl=true, $public_mode = "false", $support_email = "support@gitorious.here", $external_stylesheets = false, $common_stylesheets = false, $logo_url = false, $footer_blurb = false, $additional_view_paths  = false, $favicon_url = false, $is_gitorious_org="false", $disable_http="false",  $always_show_ssh_url=false, $system_message="", $custom_username_label=false, $disable_record_throttling=true, $enable_repository_dir_sharding=false, $enable_private_repositories=true, $repos_and_projects_private_by_default = false) {
  $file = "${gitorious::app_root}/config/gitorious.yml"
  $repository_root = $gitorious::repository_root
  $tarballs_cache = $gitorious::tarballs_cache
  $tarballs_work = $gitorious::tarballs_work

  file {$file:
    ensure => present,
    owner => "git",
    group => "git",
    content => template("gitorious/gitorious.yml.erb"),
    require => Exec["clone_gitorious_source"]
  }
}

define gitorious::custom_config($source) {
  $file = "${gitorious::app_root}/config/gitorious.yml"
  file { $file:
    ensure => present,
    owner => "git",
    group => "git",
    source => $source,
    require => Exec["clone_gitorious_source"],
    notify => File["restart.txt"],
  }
}
