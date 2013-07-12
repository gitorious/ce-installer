#!/usr/bin/ruby
$exitcode = 9999
$retry_no = 1
$max_retries = 15

`echo "Gitorious CE installer: Attempting to apply the puppet recipe" > applied_recipe.log`

while $exitcode != 512 # bitmasked "done" return code from puppet
  `echo "\n\nGitorious CE installer: Applying puppet recipe, attempt no. #{$retry_no}" >> applied_recipe.log`

  apply_output = `FACTER_fqdn=$(hostname) puppet apply --detailed-exitcodes --modulepath=modules manifests/site.pp`
  $exitcode = $?.to_i

  `echo "#{apply_output}" >> applied_recipe.log`

  `echo "\n\nGitorious CE installer: Done with attempt no. #{$retry_no}, exit code was: #{$exitcode}" >> applied_recipe.log`

  $retry_no = $retry_no + 1
  if $retry_no > $max_retries # puppet has reached steady error state, cannot complete
    `echo "\n\nGitorious CE installer: Attempted #{$retry_no} times, giving up." >> applied_recipe.log`

    puts "-----------------------------------------------------------------------------------"
    puts "FAILURE: The underlying Puppet recipe is having trouble completing the installation."
    puts "You can check what happened behind the scenes in 'applied_recipe.log' in this directory."
    puts ""
    puts "Furthermore, check that you are running in a server environment officially supported by this installer,"
    puts "or diagnose the Puppet recipe yourself by executing the following command:"
    puts ""
    puts "puppet apply --debug --modulepath=modules manifests/site.pp"
    puts "-----------------------------------------------------------------------------------"
    exit 1
  end
end
`echo "\n\nGitorious CE installer: Finished applying the recipe successfully after applying the puppet recipe #{$retry_no} times." >> applied_recipe.log`
