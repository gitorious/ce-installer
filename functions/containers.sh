LINK_MYSQL="--link gitorious-mysql:mysql --env-file=/var/lib/gitorious/env/mysql"
LINK_GIT_DAEMON="--link gitorious-git-daemon:git_daemon"
LINK_REDIS="--link gitorious-redis:redis"
LINK_MEMCACHED="--link gitorious-memcached:memcached"
LINK_POSTFIX="--link gitorious-postfix:smtp"
LINK_SPHINX="--link gitorious-sphinx:sphinx"
LINK_WEB="--link gitorious-web:web"
LINK_DATA="--volumes-from gitorious-data"

create_containers() {
  log "Creating and starting new containers..."

  # create data only container which exits immediately, with config and data volumes mapped to host

  log "  creating gitorious-data..."
  docker run --name gitorious-data -v /etc/gitorious:/srv/gitorious/config -v /var/lib/gitorious:/srv/gitorious/data -v /srv/gitorious/assets busybox /bin/true >/dev/null

  # start containers

  log "  creating gitorious-mysql..."
  docker run -d --name gitorious-mysql -v /var/lib/gitorious/mysql:/var/lib/mysql -v /var/log/gitorious/mysql:/var/log/mysql --env-file=/var/lib/gitorious/env/mysql gitorious/mysql >/dev/null

  log "  creating gitorious-redis..."
  docker run -d --name gitorious-redis -v /var/lib/gitorious/redis:/var/lib/redis -v /var/log/gitorious/redis:/var/log/redis gitorious/redis >/dev/null

  log "  creating gitorious-memcached..."
  docker run -d --name gitorious-memcached gitorious/memcached >/dev/null

  log "  creating gitorious-git-daemon..."
  docker run -d --name gitorious-git-daemon $LINK_DATA gitorious/git-daemon >/dev/null

  log "  creating gitorious-postfix..."
  docker run -d --name gitorious-postfix -h $(hostname -f) gitorious/postfix >/dev/null

  # update db schema

  log "  updating database..."
  docker run --rm $LINK_MYSQL $LINK_DATA gitorious/app bin/rake db:migrate >/dev/null

  # start more containers (ones which expect db schema to be already there + ones depending on them)

  log "  creating gitorious-git-proxy"
  docker run -d --name gitorious-git-proxy -p 9418:9418 $LINK_GIT_DAEMON $LINK_MYSQL $LINK_DATA -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/git-proxy >/dev/null

  log "  creating gitorious-queue..."
  docker run -d --name gitorious-queue $LINK_MYSQL $LINK_REDIS $LINK_MEMCACHED $LINK_POSTFIX $LINK_DATA -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/resque >/dev/null

  log "  creating gitorious-sphinx..."
  docker run -d --name gitorious-sphinx $LINK_MYSQL $LINK_DATA -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sphinx /usr/local/bin/run-sphinx >/dev/null

  log "  creating gitorious-web..."
  docker run -d --name gitorious-web $LINK_MYSQL $LINK_REDIS $LINK_MEMCACHED $LINK_SPHINX $LINK_POSTFIX $LINK_DATA -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/unicorn >/dev/null

  log "  creating gitorious-sshd..."
  docker run -d --name gitorious-sshd $LINK_WEB $LINK_REDIS -p 5022:22 $LINK_DATA -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sshd >/dev/null

  log "  creating gitorious-nginx..."
  docker run -d --name gitorious-nginx $LINK_WEB -p 80:80 $LINK_DATA -v /var/log/gitorious/nginx:/var/log/nginx gitorious/nginx >/dev/null
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
