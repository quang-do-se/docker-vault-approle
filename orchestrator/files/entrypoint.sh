#!/usr/bin/env bash


echo 'Creating orchestrator private/public key pair...'

mkdir -p /home/orchestrator/.ssh
ssh-keygen -q -t ed25519 -N '' -f /home/orchestrator/.ssh/id_ed25519 <<<y >/dev/null 2>&1
chown -R orchestrator:orchestrator /home/orchestrator/.ssh

exec /usr/sbin/gosu orchestrator "$@"
