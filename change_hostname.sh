#!/bin/sh

CURR_HOSTNAME=$(hostname)

echo "What hostname should this server and Gitorious instance have?" 
echo "(Just hit enter for current hostname '$CURR_HOSTNAME'):"

read INPUT

if [ -z "$INPUT" ]; then
  NEW_HOSTNAME=$CURR_HOSTNAME
else
  NEW_HOSTNAME=$INPUT
fi

echo "New hostname will be set to: $NEW_HOSTNAME"

EXISTING_GITORIOUS_CONFIG_FILE="/var/www/gitorious/app/config/gitorious.yml"
if [ -f $EXISTING_GITORIOUS_CONFIG_FILE ]; then
  echo "Updating Gitorious hostname setting"
  (sed -i 's/gitorious_host:.*/gitorious_host: $NEW_HOSTNAME/' /var/www/gitorious/app/config/gitorious.yml)
fi

# CentOS specific
(sed -i 's/^HOSTNAME=.*/HOSTNAME=$NEW_HOSTNAME/' /etc/sysconfig/network)
(echo "$NEW_HOSTNAME" > /proc/sys/kernel/hostname)

echo "Server and Gitorious hostname set to '$NEW_HOSTNAME'."
