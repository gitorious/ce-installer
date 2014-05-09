start_containers() {
  log "Creating and starting new containers..."

  # create data only container that exits immediately, with config and data volumes mapped to host

  log "  creating gitorious-data..."
  docker run --name gitorious-data -v /etc/gitorious:/srv/gitorious/config -v /var/lib/gitorious:/srv/gitorious/data -v /srv/gitorious/assets busybox /bin/true >/dev/null

  # start containers

  log "  creating gitorious-mysql..."
  docker run -d --name gitorious-mysql -v /var/lib/gitorious/mysql:/var/lib/mysql -v /var/log/gitorious/mysql:/var/log/mysql gitorious/mysql >/dev/null

  log "  creating gitorious-redis..."
  docker run -d --name gitorious-redis -v /var/lib/gitorious/redis:/var/lib/redis -v /var/log/gitorious/redis:/var/log/redis gitorious/redis >/dev/null

  log "  creating gitorious-memcached..."
  docker run -d --name gitorious-memcached gitorious/memcached >/dev/null

  log "  creating gitorious-git-daemon..."
  docker run -d --name gitorious-git-daemon -p 9418:9418 --volumes-from gitorious-data gitorious/git-daemon >/dev/null

  log "  creating gitorious-postfix..."
  docker run -d --name gitorious-postfix gitorious/postfix >/dev/null

  # update db schema

  log "  updating database..."
  docker run --rm --link gitorious-mysql:mysql --volumes-from gitorious-data gitorious/app bin/rake db:migrate >/dev/null

  # start more containers (which expect db schema to be already there + ones depending on them)

  log "  creating gitorious-queue..."
  docker run -d --name gitorious-queue --link gitorious-mysql:mysql --link gitorious-redis:redis --link gitorious-memcached:memcached --link gitorious-postfix:smtp --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/resque >/dev/null

  log "  creating gitorious-sphinx..."
  docker run -d --name gitorious-sphinx --link gitorious-mysql:mysql --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sphinx >/dev/null

  log "  creating gitorious-web..."
  docker run -d --name gitorious-web --link gitorious-mysql:mysql --link gitorious-redis:redis --link gitorious-memcached:memcached --link gitorious-sphinx:sphinx --link gitorious-postfix:smtp --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/unicorn >/dev/null

  log "  creating gitorious-sshd..."
  docker run -d --name gitorious-sshd --link gitorious-web:web --link gitorious-redis:redis -p 5022:22 --volumes-from gitorious-data -v /var/log/gitorious/app:/srv/gitorious/app/log -v /home/wrozka/projects/gitorious/bin/gitorious:/srv/gitorious/app/bin/gitorious gitorious/sshd >/dev/null

  log "  creating gitorious-nginx..."
  docker run -d --name gitorious-nginx --link gitorious-web:web -p 80:80 --volumes-from gitorious-data -v /var/log/gitorious/nginx:/var/log/nginx gitorious/nginx >/dev/null
}

remove_containers() {
  log "Removing old containers..."

  docker ps -a | grep "gitorious-" | awk '{print $1}' | while read cid; do
    remove_container $cid
  done
}

remove_container() {
  local name=$(docker inspect -f '{{.Name}}' $1 | awk '{print substr($0, 2)}')
  log "  removing $name..."
  docker rm -f $1 >/dev/null
}
