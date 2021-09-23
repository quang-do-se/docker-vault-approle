#!/usr/bin/env bash

BASEDIR=$(cd -- "$(dirname -- "$0")" && pwd - P)

"${BASEDIR}"/setup-ssh-authentication.ssh



run_vault_container='docker container exec -i vault'

run_app_container='docker container exec -i -u app app'

run_orchestrator_container='docker container exec -i -u orchestrator orchestrator'

secret_path='hello-world'

policy_name='hello-world-policy'



### VAULT CONTAINER

# Enable AppRole
${run_vault_container} vault auth enable approle

# Create secrets
${run_vault_container} vault kv put secret/"${secret_path}" PASSWORD1=12345 PASSWORD2=abcde

# Create role 'orchestrator'
${run_vault_container} vault write auth/approle/role/orchestrator secret_id_ttl=120m token_ttl=60m token_max_ttl=120m

# Create role 'app'
${run_vault_container} vault write auth/approle/role/app secret_id_ttl=120m token_ttl=30s token_max_ttl=60m

# Create a policy to read secret
${run_vault_container} vault policy write "${policy_name}" -<<EOF
path "secret/data/${secret_path}" {
 capabilities = ["read", "list"]
}
EOF

# Create a new policy for "orchestrator" role
${run_vault_container} vault policy write orchestrator-policy -<<EOF
path "auth/approle/role/app*" {
 capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Grant policy to orchestrator role
${run_vault_container} vault write auth/approle/role/orchestrator policies=orchestrator-policy

# Grant policy to app role 
${run_vault_container} vault write auth/approle/role/app policies=hello-world-policy

# Generate role id for orchestrator role
role_id=$(${run_vault_container} vault read -field=role_id auth/approle/role/orchestrator/role-id)

# Generate secret id for orchestrator role
secret_id=$(${run_vault_container} vault write -force -field=secret_id auth/approle/role/orchestrator/secret-id)



### ORCHESTRATOR CONTAINER

# Login as orchestrator role
token=$(${run_orchestrator_container} vault write -field=token auth/approle/login role_id="${role_id}" secret_id="${secret_id}")

${run_orchestrator_container} vault login "${token}"

# Run ansible playbook

${run_orchestrator_container} bash -c 'cd /data/ansible && ansible-playbook ansible-playbook-deploy-app.yml --inventory=inventory.yml'
