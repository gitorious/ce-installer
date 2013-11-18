#!/usr/bin/env ruby

require 'erb'

@app_root = @resque_gitorious_root = "/var/www/gitorious/app"

erb = ERB.new(File.read(ARGV[0]))
puts erb.result(binding)

