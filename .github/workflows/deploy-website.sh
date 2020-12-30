#!/bin/sh

set -e
set -x

if [ "$SSH_AGENT_PID" ]
then
   if [ ! -d $HOME/.ssh ]
   then
      mkdir -p $HOME/.ssh
      chmod 700 $HOME/.ssh
      touch $HOME/.ssh/config
      chmod 644 $HOME/.ssh/config
   fi
   echo PasswordAuthentication=no >> $HOME/.ssh/config
else
   echo "No authentication agent; skipping deployment"
fi

test -d output && mv output "$1"
sed -e "s/NAME/$1/" nginx.conf > "$1".conf

ssh-keyscan -H firehol.org >> ~/.ssh/known_hosts

ssh travis@firehol.org mkdir -p "website/$1/"
rsync -a "$1" "$1.conf" travis@firehol.org:"website/$1/"
ssh travis@firehol.org touch "website/$1/complete.txt"
