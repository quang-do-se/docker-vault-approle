### Start container

docker-compose down -v
docker-compose up -d --build && ./setup-ssh-authentication.sh


### LOGIN TO CONTAINERS

docker container exec -it vault /bin/sh

# By default, docker-compose exec attach a terminal for us, so no need for -it

docker container exec -it -u orchestrator orchestrator /bin/bash

docker container exec -it -u app app /bin/bash


# Test ssh
hostname
ssh app@app
hostname




### VAULT CONTAINER

vault kv put secret/hello-world PASSWORD1=12345 PASSWORD2=abcde
a
vault kv put -output-curl-string secret/hello-world PASSWORD1=12345 PASSWORD2=abcde0


vault auth enable approle


vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world


# Create role 'orchestrator'
vault write auth/approle/role/orchestrator secret_id_ttl=120m token_ttl=60m token_max_ttl=120m

# Create role 'app'
vault write auth/approle/role/app secret_id_ttl=120m token_ttl=30s token_max_ttl=60m

# OPTIONAL: List all roles
vault list auth/approle/role
vault policy list
vault auth list
vault policy read <policy>


# Generate role id for orchestrator
vault read -field=role_id auth/approle/role/orchestrator/role-id

# Generate secret id orchestrator
vault write -force -field=secret_id auth/approle/role/orchestrator/secret-id



### ORCHESTRATOR CONTAINER, add role id and secret id

export VAULT_ROLE_ID=
export VAULT_SECRET_ID=

vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}"

vault login <token>

# Short form
vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

# Confirm login
vault token lookup

# Try read secret
vault kv get -field=PASSWORD1 secret/hello-world



### VAULT CONTAINER

# Create a policy to read secret
vault policy write hello-world-policy -<<EOF
path "secret/data/hello-world" {
 capabilities = ["read", "list"]
}
EOF


# Create a new policy for "orchestrator" role
vault policy write orchestrator-policy -<<EOF
path "auth/approle/role/app*" {
 capabilities = ["create", "read", "update", "delete", "list"]
}
EOF





### VAULT CONTAINER

# Grant policies
vault write auth/approle/role/orchestrator policies=hello-world-policy


### ORCHESTRATOR CONTAINER
vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world


# Turn off policies
vault write auth/approle/role/orchestrator policies=

vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world


### VAULT CONTAINER

# Grant policy to orchestrator role

vault write auth/approle/role/orchestrator policies=orchestrator-policy


### ORCHESTRATOR CONTAINER

# Login again to get a new token
vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")


# Test generating role id/secret id
vault read auth/approle/role/app/role-id
vault write -force auth/approle/role/app/secret-id



### VAULT CONTAINER

# Grant policy to app role 

vault write auth/approle/role/app policies=hello-world-policy


### ORCHESTRATOR CONTAINER

# Run playbook
cd /data/ansible && ansible-playbook ansible-playbook-deploy-app.yml --inventory=inventory.yml



### APP CONTAINER
java -jar /app/spring-vault-1.0-SNAPSHOT.jar --spring.config.location=file:/app/vault.properties --spring.profiles.active=development --logging.file.path=/app/logs







### EXTRA

vault list -output-curl-string /auth/approle/role/app/secret-id

vault write auth/approle/role/app secret_id_ttl=5m secret_id_num_uses=1 token_ttl=1m token_max_ttl=1m token_num_uses=1 policies="hello-world-policy"

# token_num_uses=0: as long as token is refreshed, it live forever?
# The maximum number of times a generated token may be used (within its lifetime); 0 means unlimited. If you require the token to have the ability to create child tokens, you will need to set this value to 0.

# secret_id_num_uses: how many times secret id can be used to get a fresh token

# secret_id_ttl: how long secret id can be used to get a fresh token


vault token capabilities /auth/approle/role/app



### Demo policy

# Orchestrator cannot fetch its own role and secret ids



# docker inspect app -f "{{json .Config.Env}}" | jq

# docker inspect vault -f "{{json .NetworkSettings.Networks}}" | jq


### ITERM

# Split: cmd+d, cmd+shift+d

# maximize, minimize: cmd+shift+enter




# Generate wrapping token (wrapper for secret)
# wrapping_token=$(${run_vault_container} vault write -wrap-ttl=60s -force -field=wrapping_token auth/approle/role/_path}"/secret-id)

# Unwrap secret
# unwrapped_secred_id=$(${run_app_container} vault unwrap -field=secret_id "${wrapping_token}")
