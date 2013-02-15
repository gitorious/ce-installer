class tarball {
  define extract_and_symlink_remote_tarball(
    $url="",
    $cwd="",
    $target="",
    $owner="",
    $group="",
    $timeout=300) {


      download_file {"${name}.tar.gz":
        site => $url,
        cwd => $cwd,
        timeout => $timeout,
      }

      exec { "untar_${name}":
        command => "tar -xzf ${name}.tar.gz",
        cwd => $cwd,
        creates => "${cwd}/${name}",
        refreshonly => true,
        subscribe => Download_file["${name}.tar.gz"],
        timeout => $timeout,
      }
      file {"target":
        path => $target,
        replace => no,
        source => "${cwd}/${name}",
        subscribe => Exec["untar_${name}"],
        recurse => true,
        owner => $owner,
        group => $group,
      }
    }

    define download_file(
      $site="",
      $cwd="",
      $timeout = 300) {

        exec { $name:
          command => "wget ${site} -O ${name}",
          cwd => $cwd,
          creates => "${cwd}/${name}",
          timeout => $timeout,
        }

      }
}
