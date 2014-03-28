#!/usr/bin/env ruby

require 'erb'

@app_root = @t_app_root = @resque_gitorious_root = "/var/www/gitorious/app"
@pids_dir = "/var/www/gitorious/app/tmp/pids"
@ruby_version = ENV['FACTER_ruby_version']

erb = ERB.new(File.read(ARGV[0]))
puts erb.result(binding)

