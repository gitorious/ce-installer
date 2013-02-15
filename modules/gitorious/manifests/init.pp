import "git"
import "dependencies"
import "core"
import "templates"
import "redis"
import "sphinx"
import "logrotate"
import "no_email"
import "git_daemons"

class gitorious {
  $install_root = "/var/www/gitorious"
  $app_root = "$install_root/app"
  $deployed_tags_dir = "$install_root/deployed_tags"

  $repository_root = "$install_root/repositories"
  $tarballs_cache = "$install_root/tarballs-cache"
  $tarballs_work = "$install_root/tarballs-work"
  $passenger_version = "3.0.4"
}
