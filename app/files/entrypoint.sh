#!/usr/bin/env bash

set -eux

printf "\n\033[0;44m$(date) ---> Starting the SSH server.\033[0m\n"

service ssh start
service ssh status


mkdir -p /home/app/.ssh
chown -R app:app /home/app/.ssh

exec /usr/sbin/gosu app "$@"
