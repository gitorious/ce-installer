#!/usr/bin/env ruby 

current_hostname = `hostname`.chomp

puts "What hostname should this server and Gitorious instance have?" 
puts "(Just hit enter for current hostname '#{current_hostname}'):"
input = gets.chomp

if input.empty? 
  new_hostname = current_hostname
else
  new_hostname = input
end

if File.exist?("/var/www/gitorious/app/config/gitorious.yml")
  puts "Updating Gitorious hostname setting"
  `sed -i 's/gitorious_host:.*/gitorious_host: #{new_hostname}/' /var/www/gitorious/app/config/gitorious.yml`
end

# CentOS specific
`sed -i 's/^HOSTNAME=.*/HOSTNAME=#{new_hostname}/' /etc/sysconfig/network`
`echo "#{new_hostname}" > /proc/sys/kernel/hostname`

puts "Server and Gitorious hostname set to '#{new_hostname}'."
