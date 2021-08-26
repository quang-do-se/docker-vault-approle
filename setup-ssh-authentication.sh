#!/usr/bin/env bash

echo 'Creating orchestrator private public keys...'

docker-compose exec -T orchestrator ssh-keygen -t rsa -f /home/orchestrator-user/.ssh/id_rsa -q -N "" <<<y &>/dev/null

public_key=$(docker-compose exec -T orchestrator cat /home/orchestrator-user/.ssh/id_rsa.pub)


echo "Adding orchestrator public keys to app's authorized keys..."

docker-compose exec -u app-user -T app sh -c "echo ${public_key} > /home/app-user/.ssh/authorized_keys"


echo "Adding app to orchestrator's known hosts..."

docker-compose exec -T orchestrator sh -c "ssh-keyscan -t rsa app > /home/orchestrator-user/.ssh/known_hosts 2>/dev/null" 


echo "DONE!"
