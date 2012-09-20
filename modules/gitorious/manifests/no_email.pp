class gitorious::no_email {
  file { "disable_email.rb":
    path => "${gitorious::app_root}/config/initializers/disable_email.rb",
    owner => "git",
    group => "git",
    require => File["/etc/gitorious.conf"],
    content => "ActionMailer::Base.delivery_method = :test",
    ensure => present,
  }
}
