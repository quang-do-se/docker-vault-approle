#!/usr/bin/env bash

# Set up user with matching host's uid and gid (Linux specific issue)

USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}


echo "UID: $USER_ID, GID: $GROUP_ID"

groupadd --gid $GROUP_ID --system orchestrator;
useradd --uid $USER_ID --system --shell /bin/bash --create-home --gid orchestrator orchestrator;


echo 'Creating orchestrator private/public key pair...'

mkdir -p /home/orchestrator/.ssh
ssh-keygen -q -t ed25519 -N '' -f /home/orchestrator/.ssh/id_ed25519 <<<y >/dev/null 2>&1

chown -R orchestrator:orchestrator /home/orchestrator


export HOME=/home/orchestrator


exec /usr/sbin/gosu orchestrator "$@"
