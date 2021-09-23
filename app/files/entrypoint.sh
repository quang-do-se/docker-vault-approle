#!/usr/bin/env bash

set -eux

printf "\n\033[0;44m$(date) ---> Starting the SSH server.\033[0m\n"

service ssh start
service ssh status


# Set up user with matching host's uid and gid (Linux specific issue)

USER_ID=${LOCAL_UID:-9999}
GROUP_ID=${LOCAL_GID:-9999}

echo "UID: $USER_ID, GID: $GROUP_ID"

groupadd --gid $GROUP_ID --system app;
useradd --uid $USER_ID --system --shell /bin/bash --create-home --gid app app;

mkdir -p /home/app/.ssh;
chown -R app:app /home/app

export HOME=/home/app

exec /usr/sbin/gosu app "$@"
