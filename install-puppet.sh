#!/bin/bash

PUPPET_VERSION=2.7.11

if which puppet > /dev/null && [ `puppet --version` != $PUPPET_VERSION ] ; then 
  EXISTING_VERSION=`puppet --version`
  echo "You already have puppet installed in version $EXISTING_VERSION. This may cause conflicts with version installed by Gitorious ($PUPPET_VERSION)."

  read -p "Do you want to continue? [y/N]" -r
  echo
  if ! [[ $REPLY =~ ^[Yy]$ ]] ; then
    exit 1
  fi
fi

gem install -y --no-ri --no-rdoc puppet -v=$PUPPET_VERSION
