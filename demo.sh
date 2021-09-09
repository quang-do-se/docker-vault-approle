### Start container

docker-compose down -v
docker-compose up -d --build && ./setup-ssh-authentication.sh


### LOGIN TO CONTAINERS

docker-compose exec vault /bin/sh

docker-compose exec orchestrator /bin/bash

docker-compose exec -u app-user app /bin/bash

### VAULT CONTAINER



vault auth enable approle

vault kv put secret/hello-world PASSWORD1=12345 PASSWORD2=abcde

vault policy write hello-world-policy -<<EOF
path "secret/data/hello-world" {
 capabilities = ["read", "list"]
}
EOF

# Create role 'orchestrator'
vault write auth/approle/role/orchestrator secret_id_ttl=120m token_ttl=60m token_max_ttl=120m

# OPTIONAL: List all roles
vault list auth/approle/role
vault policy list
vault policy read <policy>


# Generate role id
vault read -field=role_id auth/approle/role/orchestrator/role-id

# Generate secret id
vault write -force -field=secret_id auth/approle/role/orchestrator/secret-id





### ORCHESTRATOR CONTAINER

# Store role id and secret id in environment variables or configuration file

export VAULT_ROLE_ID=
export VAULT_SECRET_ID=

vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world


### APP CONTAINER

# Assign policy to role
vault write auth/approle/role/orchestrator policies=hello-world-policy


### ORCHESTRATOR CONTAINER

# Try again, need new token
vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world





### PART II

### VAULT CONTAINER

# Create a new role "app" with "hello-world-policy"
vault write auth/approle/role/app secret_id_ttl=120m token_ttl=60m token_max_ttl=120m token_num_uses=0 policies="hello-world-policy"


# Create a new policy for "app" role
vault policy write ochestrator-policy -<<EOF
path "auth/approle/role/app*" {
 capabilities = ["create", "read", "update", "delete", "list", "root"]
}
EOF

# Give orchestrator new policy
vault write auth/approle/role/orchestrator policies=ochestrator-policy



### ORCHESTRATOR CONTAINER

# Login again to get a new token
vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

# Test generating role id/secret id
vault read -field=role_id auth/approle/role/app/role-id
vault write -force -field=secret_id auth/approle/role/app/secret-id


# Run playbook
cd /data/files && ansible-playbook ansible-playbook-deploy-app.yml --inventory=inventory.yml



### APP CONTAINER
java -jar /app/spring-vault-1.0-SNAPSHOT.jar --spring.config.location=file:/app/vault.properties





### EXTRA

vault list -output-curl-string /auth/approle/role/app/secret-id

vault write auth/approle/role/app secret_id_ttl=5m secret_id_num_uses=1 token_ttl=1m token_max_ttl=1m token_num_uses=1 policies="hello-world-policy"

# token_num_uses=0: as long as token is refreshed, it live forever?
# The maximum number of times a generated token may be used (within its lifetime); 0 means unlimited. If you require the token to have the ability to create child tokens, you will need to set this value to 0.

# secret_id_num_uses: how many times secret id can be used to get a fresh token

# secret_id_ttl: how long secret id can be used to get a fresh token


### Demo policy

# Orchestrator cannot fetch its own role and secret ids



# docker inspect app -f "{{json .Config.Env}}" | jq

# docker inspect vault -f "{{json .NetworkSettings.Networks}}" | jq
