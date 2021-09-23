#!/usr/bin/env bash

set -e
 
printf "\n\033[0;44m$(date) ---> Starting the SSH server.\033[0m\n"
 
service ssh start
service ssh status


USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"

usermod -u $USER_ID app
groupmod -g $GROUP_ID app

export HOME=/home/app

exec /usr/sbin/gosu app "$@"
