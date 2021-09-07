### Start container

docker-compose down -v && docker-compose up -d --build && ./setup-ssh-authentication.sh

### VAULT CONTAINER
docker-compose exec vault /bin/sh

vault auth enable approle

vault kv put secret/hello-world PASSWORD1=12345 PASSWORD2=abcde

vault policy write hello-world-policy -<<EOF
path "secret/data/hello-world" {
 capabilities = ["read", "list"]
}
EOF

# Create role 'orchestrator'
vault write auth/approle/role/orchestrator secretid_ttl=120m token_ttl=60m token_max_tll=120m

# OPTIONAL: List all roles
vault list auth/approle/role
vault policy list
vault policy read <policy>


# Generate role id
vault read -field=role_id auth/approle/role/orchestrator/role-id

# Generate secret id
vault write -force -field=secret_id auth/approle/role/orchestrator/secret-id




### ORCHESTRATOR CONTAINER

docker-compose exec orchestrator /bin/bash

# Store role id and secret id in environment variables or configuration file

export VAULT_ROLE_ID=
export VAULT_SECRET_ID=

vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world


docker-compose exec vault /bin/sh

# Assign policy to role
vault write auth/approle/role/orchestrator policies=hello-world-policy

docker-compose exec orchestrator /bin/bash

# Try again, need new token
vault login $(vault write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")

vault kv get -field=PASSWORD1 secret/hello-world
vault kv get -field=PASSWORD2 secret/hello-world




### PART II

### VAULT CONTAINER

# Create a new role "app" with "hello-world-policy"
vault write auth/approle/role/app secretid_ttl=120m token_ttl=60m token_max_tll=120m policies="hello-world-policy"


# Create a new policy for "app" role
vault policy write app-policy -<<EOF
path "auth/approle/role/app/*" {
 capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Give orchestrator new policy
vault write auth/approle/role/orchestrator policies=app-policy


### ORCHESTRATOR CONTAINER

# Generate role id
vault read -field=role_id auth/approle/role/app/role-id

# Generate secret id
vault write -force -field=secret_id auth/approle/role/app/secret-id

cd /data/files

ansible-playbook ansible-playbook-deploy-app.yml --inventory=inventory.yml


### APP CONTAINER

cd /app && java -jar spring-vault-1.0-SNAPSHOT.jar --spring.config.location=file:/app/vault.properties
