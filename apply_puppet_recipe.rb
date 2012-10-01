#!/usr/bin/ruby
$exitcode = -1
$retries = 0
$max_retries = 15
while $exitcode != 0
  `puppet apply --detailed-exitcodes --modulepath=modules manifests/site.pp`
  $exitcode = $?
  $retries = $retries + 1
  if $retries > $max_retries # puppet has reached steady error state, cannot complete
    puts "-----------------------------------------------------------------------------------"
    puts "FAILURE: The underlying Puppet recipe is having trouble completing the installation."
    puts "Check that you are running in a server environment officially supported by this installer," 
    puts "or diagnose the Puppet recipe yourself by executing this command:\n"
    puts ""
    puts "puppet apply --debug --detailed-exitcodes --modulepath=modules manifests/site.pp" 
    puts "-----------------------------------------------------------------------------------"
    exit 1
  end
end
