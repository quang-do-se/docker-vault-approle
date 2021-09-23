#!/usr/bin/env bash

set -e

USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"

usermod -u $USER_ID orchestrator
groupmod -g $GROUP_ID orchestrator

export HOME=/home/orchestrator

exec /usr/sbin/gosu orchestrator "$@"
