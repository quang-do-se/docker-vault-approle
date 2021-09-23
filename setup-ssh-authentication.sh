#!/usr/bin/env bash

set -eu -o pipefail



echo 'Copying orchestrator public keys...'

public_key=$(docker container exec -i orchestrator cat /home/orchestrator/.ssh/id_ed25519.pub)



echo "Adding orchestrator public keys to app's authorized keys..."

docker container exec -i --user app app sh -c "echo ${public_key} > /home/app/.ssh/authorized_keys"



echo "Set password for app"

docker container exec -i --user root app sh -c "echo 'app:app-pass' | chpasswd;"



echo "DONE!"
