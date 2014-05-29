class gitorious::assets {
  Exec { path => ["/opt/rubies/ruby-${ruby_version}/bin/","/usr/local/bin","/usr/bin","/bin"] }

  exec {"precompile_assets":
    command => "${gitorious::app_root}/bin/rake assets:precompile && touch ${gitorious::app_root}/tmp/assets_precompiled",
    creates => "${gitorious::app_root}/tmp/assets_precompiled",
    require => [ Exec["bundle_install"] ],
  }

}
