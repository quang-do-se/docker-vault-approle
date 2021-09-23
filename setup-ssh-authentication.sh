#!/usr/bin/env bash

set -eu -o pipefail



echo 'Creating orchestrator private/public key pair...'

docker container exec -i orchestrator bash -c "ssh-keygen -q -t ed25519 -N '' -f /home/orchestrator-user/.ssh/id_ed25519 <<<y >/dev/null 2>&1"



echo 'Copying orchestrator public keys...'

public_key=$(docker container exec -i orchestrator cat /home/orchestrator-user/.ssh/id_ed25519.pub)



echo "Adding orchestrator public keys to app's authorized keys..."

docker container exec -i -u app-user app sh -c "echo ${public_key} > /home/app-user/.ssh/authorized_keys"



echo "Set password for app-user"

docker container exec -i -u root app sh -c "echo 'app-user:app-pass' | chpasswd;"



echo "DONE!"
