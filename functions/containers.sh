start_containers() {
  log "Creating and starting new containers..."

  # create data only container that exits immediately, with config and data volumes mapped to host
  docker run --name gitorious-data -v /etc/gitorious:/srv/gitorious/config -v /var/lib/gitorious:/srv/gitorious/data -v /srv/gitorious/assets busybox /bin/true

  # start containers
  docker run -d --name gitorious-mysql -v /var/lib/gitorious/mysql:/var/lib/mysql -v /var/log/gitorious/mysql:/var/log/mysql gitorious/mysql
  docker run -d --name gitorious-redis -v /var/lib/gitorious/redis:/var/lib/redis -v /var/log/gitorious/redis:/var/log/redis gitorious/redis
  docker run -d --name gitorious-memcached gitorious/memcached
  docker run -d --name gitorious-git-daemon -p 9418:9418 --volumes-from gitorious-data gitorious/git-daemon
  docker run -d --name gitorious-postfix gitorious/postfix

  # update db schema
  docker run --rm --link gitorious-mysql:mysql --volumes-from gitorious-data gitorious/app bin/rake db:migrate

  # start more containers (which expect db schema to be already there)
  docker run -d --name gitorious-queue --link gitorious-mysql:mysql --link gitorious-redis:redis --link gitorious-memcached:memcached --link gitorious-postfix:smtp --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/resque
  docker run -d --name gitorious-sphinx --link gitorious-mysql:mysql --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sphinx
  docker run -d --name gitorious-web --link gitorious-mysql:mysql --link gitorious-redis:redis --link gitorious-memcached:memcached --link gitorious-sphinx:sphinx --link gitorious-postfix:smtp --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/unicorn
  docker run -d --name gitorious-sshd --link gitorious-web:web -p 5022:22 --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sshd
  docker run -d --name gitorious-nginx --link gitorious-web:web -p 80:80 --volumes-from gitorious-data -v /var/log/gitorious/nginx:/var/log/nginx gitorious/nginx
}

remove_containers() {
  log "Removing old containers..."

  docker ps -a | grep "gitorious-" | awk '{print $1}' | xargs -r docker rm -f
}
