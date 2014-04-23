#!/bin/bash

set -e
set -x

# echo -e "\e[42m+\e[41m-\e[0m \e[1mGitorious\e[0m"

TAG=${TAG:-latest}

# disable automatic restarting of containers by docker himself (we use upstart for monitoring)
echo 'DOCKER_OPTS="-r=false"' >/etc/default/docker
restart docker
sleep 5

# fetch latest containers from docker index
docker pull gitorious/mysql
docker pull gitorious/redis
docker pull gitorious/memcached
docker pull gitorious/git-daemon
docker pull gitorious/app
docker pull gitorious/nginx
docker pull gitorious/sphinx
docker pull gitorious/postfix

docker rm -f data mysql redis memcached git-daemon postfix queue sphinx web sshd nginx

# create data only container that exits immediately, with config and data volumes mapped to host
docker run --name data -v /etc/gitorious:/srv/gitorious/config -v /var/lib/gitorious:/srv/gitorious/data tianon/true

# start named containers
docker run -d --name mysql -v /var/lib/gitorious/mysql:/var/lib/mysql -v /var/log/gitorious/mysql:/var/log/mysql gitorious/mysql
docker run -d --name redis -v /var/lib/gitorious/redis:/var/lib/redis -v /var/log/gitorious/redis:/var/log/redis gitorious/redis
docker run -d --name memcached gitorious/memcached
docker run -d --name git-daemon -p 9418:9418 --volumes-from data gitorious/git-daemon
docker run -d --name postfix gitorious/postfix

# create db tables
docker run --rm --link mysql:mysql --volumes-from data gitorious/app bin/rake db:migrate

# start more named containers
docker run -d --name queue --link mysql:mysql --link redis:redis --link memcached:memcached --link postfix:smtp --volumes-from data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app bin/resque
docker run -d --name sphinx --link mysql:mysql --volumes-from data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sphinx
docker run -d --name web --link mysql:mysql --link redis:redis --link memcached:memcached --link sphinx:sphinx --link postfix:smtp --volumes-from data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/app /bin/sh -c "sleep 10 && bin/unicorn"
docker run -d --name sshd --link web:web --volumes-from data -v /var/log/gitorious/app:/srv/gitorious/app/log gitorious/sshd
docker run -d --name nginx --link web:web -p 80:80 --volumes-from data -v /var/log/gitorious/nginx:/var/log/nginx gitorious/nginx
