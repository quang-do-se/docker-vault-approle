#!/usr/bin/env bash

run_vault_container='docker-compose exec -T vault'

run_app_container='docker-compose exec -T app'

secret_path='hello-world'

policy_name='hello-world-policy'



### VAULT CONTAINER

# Enable AppRole
${run_vault_container} vault auth enable approle

# Create secrets
${run_vault_container} vault kv put secret/"${secret_path}" PASSWORD1=12345 PASSWORD2=abcde

# Create policy
${run_vault_container} vault policy write "${policy_name}" -<<EOF
path "secret/data/${secret_path}" {
 capabilities = ["read", "list"]
}
EOF

# Create role
${run_vault_container} vault write auth/approle/role/${secret_path} secretid_ttl=120m token_ttl=60m token_max_tll=120m policies="${policy_name}"

# Generate role id
role_id=$(${run_vault_container} vault read -field=role_id auth/approle/role/"${secret_path}"/role-id)

# Generate secret id directly
secret_id=$(${run_vault_container} vault write -force -field=secret_id auth/approle/role/"${secret_path}"/secret-id)

# Generate wrapping token (wrapper for secret)
wrapping_token=$(${run_vault_container} vault write -wrap-ttl=60s -force -field=wrapping_token auth/approle/role/"${secret_path}"/secret-id)



### APP CONTAINER

# Unwrap secret
unwrapped_secred_id=$(${run_app_container} vault unwrap -field=secret_id "${wrapping_token}")

# Request new token
token=$(${run_app_container} vault write -field=token auth/approle/login role_id="${role_id}" secret_id="${unwrapped_secred_id}")

# Store token
${run_app_container} sh -c "echo ${token} > ~/.vault-token"



### TEST RETRIEVING SECRETS
echo

echo 'Quick test...'
echo 'First password:' $(${run_app_container} vault kv get -field=PASSWORD1 secret/"${secret_path}")
echo 'Second password:' $(${run_app_container} vault kv get -field=PASSWORD2 secret/"${secret_path}")
echo

echo "Role id: ${role_id}"
echo "Secret id: ${secret_id}"
echo "Wrapping token: ${wrapping_token}"
echo "Unwrapped secred id: ${secret_id}"
echo "Token: ${token}"
echo



### RETRIEVE SECRETS WITH SPRING VAULT
echo "Retrieving secrets with Spring Vault. This may take a while..."

docker-compose exec -T \
               -e VAULT_URI='http://vault:8200' \
               -e VAULT_APP_ROLE_ROLE_ID="${role_id}" \
               -e VAULT_APP_ROLE_SECRET_ID="${secret_id}" \
               -w /projects/spring-vault \
               app \
               gradle clean run
