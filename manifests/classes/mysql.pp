class mysql {
  define create_database($username, $password) {
    exec { "create_database_$name":
      command => "echo 'create database if not exists ${name}; grant all on ${name}.* to \"${username}\"@\"localhost\" identified by \"${password}\"' | mysql",
      creates => "/var/lib/mysql/$name",
      require => Service["mysqld"],
    }
  }
}
