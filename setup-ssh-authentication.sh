#!/usr/bin/env bash

set -eu -o pipefail



echo 'Copying orchestrator public keys...'

public_key=$(docker-compose exec -T orchestrator cat /home/orchestrator-user/.ssh/id_ed25519.pub)



echo "Adding orchestrator public keys to app's authorized keys..."

docker-compose exec -u app-user -T app sh -c "echo ${public_key} > /home/app-user/.ssh/authorized_keys"



echo "Set password for app-user"

docker-compose exec -u root -T app sh -c "echo 'app-user:app-pass' | chpasswd;"



echo "DONE!"
